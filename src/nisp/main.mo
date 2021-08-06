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

    var metatree = MetaTree.MetaTree(#local);

    var broadcastLogItemIndex : [MetaTree.MetaTreeIndex] = [
        {namespace = "com.dRoute.eventbroadcast.__eventDRouteID"; dataZone=3; dataChunk=0; indexType = #Nat;},
        {namespace = "com.dRoute.eventbroadcast.__eventUserID"; dataZone=4; dataChunk=0; indexType = #Nat;},
        {namespace = "com.dRoute.eventbroadcast.__subscriptionDRouteID"; dataZone=8; dataChunk=0; indexType = #Nat;},
        {namespace = "com.dRoute.eventbroadcast.__subscriptionUserID"; dataZone=7; dataChunk=0; indexType = #Nat;}
    ];




    public shared(msg) func getWitness(_request : NIspTypes.GetWitnessRequest) : async Result.Result<NIspTypes.GetWitnessResponse, DRouteTypes.PublishError>{

        Debug.print("returning no record");
        return #ok(#noRecord);

        //return #err({code=404; text="not implemented subscribe"})
    };



    system func preupgrade() {


    };

    system func postupgrade() {


    };


};

