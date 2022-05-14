//import RegCanister "canister:droute";
//import UtilityTestCanister "canister:test_runner_droute_utilities";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import C "mo:matchers/Canister";
import DRouteTypes "../droute_2/types";
import Debug "mo:base/Debug";
import M "mo:matchers/Matchers";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Array "mo:base/Array";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Candy "mo:candy/types";
import dRoutePublisher "../droute_2/publisher";
import dRouteRegistration "../droute_2/registration";

import ExperimentalCycles "mo:base/ExperimentalCycles";

actor class test_droute_2() = this {



    //let recievedEvents : Buffer.Buffer<DRouteTypes.DRouteEvent> = Buffer.Buffer<DRouteTypes.DRouteEvent>(16);
    //dummy instantiation...reset in each test
    var dRoutePub = dRoutePublisher.dRoutePublisher(#StartUp({
            self = Principal.fromText("aaaaa-aa");
            reg_canister = Principal.fromText("aaaaa-aa");
            onEventPublished = null
        }));

    public shared func test() : async {#success; #fail : Text} {
        Debug.print("running tests for droute_2");

        let suite = S.suite("test publisher", [
                    S.test("test getPublishingCanisters", switch(await testGetPublishingCanisters()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    
                ]);
        S.run(suite);



        return #success;

    };


    public shared func testGetPublishingCanisters() : async {#success; #fail : Text} {
        Debug.print("running testGetPublishingCanisters");

        let regCanister = await dRouteRegistration.DRouteRegistration();

        dRoutePub := dRoutePublisher.dRoutePublisher(#StartUp({
            self = Principal.fromActor(this);
            reg_canister = Principal.fromActor(regCanister);
            onEventPublished = null;
        }));
            
        Debug.print("should have called");
        let regResult = dRoutePub.syncRegistration();
        Debug.print("did it callcalled");

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round");
            let result = await regCanister.getMetrics_reg_droute();
            if(dRoutePub.b_registration_updated == true){
                break waitForResponse;
            };
        };

        

        let suite = S.suite("test testGetPublishingCanisters", [
            S.test("registration size is updated", dRoutePub.b_registration_updated, M.equals<Bool>(T.bool(true))), //update to actual value when allocations occur
            S.test("registration is regcanister", if(dRoutePub.get_publishing_canisters().size() == 1){
                Principal.toText(dRoutePub.get_publishing_canisters()[0])
            } else{"notaprincipal"}, M.equals<Text>(T.text(Principal.toText(Principal.fromActor(regCanister))))) //update to allocation when set up
        ]);

        Debug.print("running suite");
        S.run(suite);
        Debug.print("suite done");

        return #success;


    };


    public func get_publishing_canisters_confirm_droute(items: [Principal]) : (){
        Debug.print("get_publishing_canisters_confirm_droute was called with " # debug_show(items));
        let result = dRoutePub.syncRegistrationConfirm(items);
        return;
    };

    /* public func __dRouteSubValidate(principal : Principal.Principal, userID: Nat) : async (Bool, Blob, DRouteTypes.MerkleTreeWitness){

        return (true, Blob.fromArray([1:Nat8]), #empty);
    };

    public shared func testSubscribe() : async {#success; #fail : Text} {
        Debug.print("running testSubscribe");

        let dRouteList  = dRouteListener.dRouteListener({regPrincipal = initArgs.regPrincipal});

        let eventSub : DRouteTypes.SubscriptionRequest = {
            eventType = "test123";
            filter : ?DRouteTypes.SubscriptionFilter = null;
            throttle: ?DRouteTypes.SubscriptionThrottle = null;
            destinationSet = [Principal.fromActor(this)];//send notifications to this canister
            userID = 1;
        };

        Debug.print(debug_show(eventSub));


        let result = await dRouteList.subscribe(eventSub);

        let pubCanister : DRouteTypes.PublishingCanisterActor = actor(Principal.toText(dRouteList.regPrincipal));


        let pubResult = await pubCanister.publish({
            eventType = "test123";
            userID = 2;
            dataConfig = #dataIncluded{
            data = [(0,0,#Bytes(#frozen([1:Nat8,2:Nat8,3:Nat8,4:Nat8])))]};
        });

        Debug.print("pubResult " # debug_show(pubResult));

        var pendingItems = true;
        var handbreak = 0;
        label clearQueue while(pendingItems == true){
            handbreak +=1;
            if(handbreak > 1000){
                return #fail("handbreak overrun");
            };
            let processResult = await pubCanister.processQueue();
            Debug.print("processResult " # debug_show(processResult));
            switch(processResult){
                case(#ok(aResult)){
                    if(aResult.queueLength == 0){
                        pendingItems := false;
                    } else {
                        recievedEvents.clear();
                    };
                };
                case(#err(aErr)){
                    return #fail(aErr.text);
                };
            };

        };


        //result should now be saved in another var
        var bMessageDelivered : Bool = false;

        Debug.print("recievedevents " # debug_show(recievedEvents.size()));
        for(thisItem in recievedEvents.vals()){
            Debug.print("an Item " # debug_show(thisItem.eventType) # " " # debug_show(thisItem.userID));
            if(thisItem.eventType == "test123" and thisItem.userID == 2){
                bMessageDelivered := true;
            }
        };

        //check to see if the publish is in the logs
        Debug.print("getting logs");
        var logs = await pubCanister.getProcessingLogs("test123");
        //Debug.print(debug_show(logs.data.size()) # " full log " # debug_show(logs));


        switch(logs){
            case(#pointer(logs)){
                return #fail("returned a pointer");
            };
            case(#notFound){
                return #fail("returned a not found");
            };
            case(#data(logs)){
                let logArray = Array.map<MetaTree.Entry, ?DRouteTypes.BroadcastLogItem>(logs.data, func(a){
                    DRouteUtilities.deserializeBroadcastLogItem(a.data);
                });


                let dataSize = logs.data.size();
                let lastlog = DRouteUtilities.deserializeBroadcastLogItem(logs.data[dataSize-1].data);
                Debug.print("last log " # debug_show(lastlog));



                //Debug.print("full log "# debug_show(logArray));

                switch(result, pubResult, lastlog){
                    case(#ok(result), #ok(pubResult), ?lastlog){
                        var eventDRouteIDLogs = await pubCanister.getProcessingLogsByIndex("__eventDRouteID", pubResult.dRouteID);
                        var eventUserIDLogs = await pubCanister.getProcessingLogsByIndex("__eventUserID", 2);
                        var subscriptionDRouteIDLogs = await pubCanister.getProcessingLogsByIndex("__subscriptionDRouteID", result.subscriptionID);
                        var subscriptionUserIDLogs = await pubCanister.getProcessingLogsByIndex("__subscriptionUserID", 1);

                        switch(eventDRouteIDLogs, eventUserIDLogs, subscriptionDRouteIDLogs, subscriptionUserIDLogs){
                            case(#data(eventDRouteIDLogs),#data(eventUserIDLogs),#data(subscriptionDRouteIDLogs),#data(subscriptionUserIDLogs)){
                                var eventDRouteIDLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(eventDRouteIDLogs.data[eventDRouteIDLogs.data.size()-1].data));
                                var eventUserIDLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(eventUserIDLogs.data[eventUserIDLogs.data.size()-1].data));
                                var subscriptionDRouteIDLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(subscriptionDRouteIDLogs.data[subscriptionDRouteIDLogs.data.size()-1].data));
                                var subscriptionUserIDLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(subscriptionUserIDLogs.data[subscriptionUserIDLogs.data.size()-1].data));

                                Debug.print("running suite" # debug_show(result));

                                let suite = S.suite("test subscribe", [
                                    S.test("subscription id exists", result.subscriptionID, M.anything<Int>()),
                                    //todo test the signature

                                    ///test that the event was recieved
                                    S.test("message was recived", bMessageDelivered : Bool, M.equals<Bool>(T.bool(true))),
                                    ///test that the event was logged
                                    S.test("log was written userID", lastlog.eventUserID : Nat, M.equals<Nat>(T.nat(2))),
                                    S.test("log was written eventType", lastlog.eventType : Text, M.equals<Text>(T.text("test123"))),
                                    S.test("log was written eventdrouteID", lastlog.eventDRouteID : Nat, M.equals<Nat>(T.nat(pubResult.dRouteID))),

                                    ///test indexes were created
                                    S.test("index event droute id was written", eventDRouteIDLog.eventDRouteID : Nat, M.equals<Nat>(T.nat(pubResult.dRouteID))),
                                    S.test("index event user id was written", eventUserIDLog.eventUserID : Nat, M.equals<Nat>(T.nat(2))),
                                    S.test("index subscription droute id was written", subscriptionDRouteIDLog.eventDRouteID : Nat, M.equals<Nat>(T.nat(pubResult.dRouteID))),
                                    S.test("index subscription user id was written", subscriptionUserIDLog.eventUserID : Nat, M.equals<Nat>(T.nat(2))),



                                ]);

                                S.run(suite);

                                return #success;
                            };
                            case(_,_,_,_){
                                Debug.print("an error pointer result" # debug_show(result));
                                return #fail("check logs for pointer");
                            };
                        };
                    };
                    case(#err(err), _, _){
                        Debug.print("an error sub result" # debug_show(result));
                        return #fail(err.text);
                    };
                    case(_, #err(err), _){
                        Debug.print("an error pubresult" # debug_show(result));
                        return #fail(err.text);
                    };
                    case(_,_,_){
                        Debug.print("an error pubresult" # debug_show(result));
                        return #fail("err.text");
                    };
                };
            };

        };


    }; */




};