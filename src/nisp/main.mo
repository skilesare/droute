import Buffer "mo:base/Buffer";
import NIspTypes "../nispTypes";
import DRouteTypes "../DRouteTypes";
import DRouteUtilities "../DRouteUtilities";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Heap "mo:base/Heap";
import Int "mo:base/Int";
import List "mo:base/List";
import MetaTree "../metatree";
import MerkleTree "../dRouteUtilities/MerkleTree";
import Nat "mo:base/Nat";
import Order "mo:base/Order";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrixTypes "../TrixTypes/lib";


actor class NIsp() = this {




    ///////////////////////////////////
    // todo: this may need to be in the reg canister and a comprable structure in each publishing canister
    ///////////////////////////////////
        stable var upgradeEventRegistration: [DRouteTypes.EventRegistrationStable] = [];

        var registrationStore = HashMap.HashMap<Text, DRouteTypes.EventRegistration>(
            1,
            Text.equal,
            Text.hash
        );
    ///////////////////////////////////
    // /end shared structure
    ///////////////////////////////////




    stable var merkleRollUp  = MerkleTree.empty();

    //todo: make metatree stable
    var metatree = MetaTree.MetaTree(#local);


    //var broadcastLogItemIndex : [MetaTree.MetaTreeIndex] = [
    //    {namespace = "com.nisp.cycleWitness.__eventDRouteID"; dataZone=3; dataChunk=0; indexType = #Nat;},
    //
    //];

    func pricipalAsNat(principal : Principal) : Nat{
        TrixTypes.bytesToNat(TrixTypes.principalToBytes(principal));
    };

    func getBalanceWitness(principal : Principal) : NIspTypes.BalanceWitness {

        //todo: make sure the caller isnt anonymous

        //todo: highly inefficent becaue it converst to text
        Debug.print("in get balance witness " # debug_show(principal));
        let thisPrincipal = pricipalAsNat(principal);
        let witness = metatree.getWitnessByNamespace("com.nisp.balance." # Principal.toText(principal), thisPrincipal, 0);
        Debug.print("found Witness" # debug_show(witness));
        let balanceRecord = metatree.readUnique("com.nisp.balance." # Principal.toText(principal), thisPrincipal);
        Debug.print("found balance" # debug_show(balanceRecord));
        switch(witness, balanceRecord){
            case(#finalWitness(witness), #data(balanceRecord)){
                Debug.print("handling balance and witness");
                if(balanceRecord.data.size() == 0){
                    return #notFound(witness);
                } else {
                    let thisChunk = balanceRecord.data[0].data;
                    return #found({
                            balance = TrixTypes.bytesToNat(TrixTypes.getDataChunkFromAddressedChunkArray(thisChunk,0,0));
                            witness = witness;
                        });
                };
            };
            case(#pointer(aPointer),#pointer(bPointer)){
                //todo: document how a witness principal must be on the same canister as the response
                Debug.print("in pointer");
                assert(aPointer.canister == bPointer.canister);
                return #pointer({
                        canister = aPointer.canister;
                        witness = aPointer.witness;
                    });
            };
            case(_,_){
                Debug.print("Shouldnt be here");
                return #err({code=404; text="not implemented subscribe"});
            };
        };
        //return #ok();

        return #err({code=404; text="not implemented subscribe"})
    };


    public  shared query(msg)  func getStatus() : async Result.Result<NIspTypes.GetStatusResponse, DRouteTypes.PublishError>{

        Debug.print("getting status");
        var currentWitness =  getBalanceWitness(msg.caller);
        Debug.print("have witess " # debug_show(currentWitness));
        switch(currentWitness){
            case(#notFound(result)){
                return #ok(#notFound(result));
            };
            case(#found(result)){
                return #ok(#cycleBalance((result.balance, result.witness)));
            };
            case(#pointer(result)){
                return #ok(#pointer((result.canister, result.witness)));
            };
            case(#err(err)){
                return #err(err);
            };

        };
        Debug.print("returning no record");
        //return #ok(#not);

        return #err({code=404; text="not implemented subscribe"})
    };

    public shared(msg) func updateCycles(principal : Principal, cycles : Nat) : async Bool{
        //todo: only allow for controler
        //todo: never set for anonymous
        Debug.print("adding cylces to principal" # debug_show(pricipalAsNat(principal)));
        let marker = await metatree.replace("com.nisp.balance." # Principal.toText(principal),
            pricipalAsNat(principal),
            #dataIncluded({data = [(0,0,TrixTypes.natToBytes(cycles))]}),
            true);
        //marker should be 0
        Debug.print(debug_show(marker));
        return true;
    };

    public shared(msg) func __resetTest() : async Bool{
        //todo: only allow for controler
        //todo: never set for anonymous

        let marker = await metatree.__resetTest();
        //marker should be 0
        Debug.print("reseting metatree");
        return true;
    };



    system func preupgrade() {


    };

    system func postupgrade() {


    };


};

