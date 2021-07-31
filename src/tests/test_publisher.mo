//import RegCanister "canister:droute";
//import UtilityTestCanister "canister:test_runner_droute_utilities";
import C "mo:matchers/Canister";
import DRouteTypes "../DRouteTypes/lib";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import M "mo:matchers/Matchers";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import TrixTypes "../TrixTypes/lib";
import dRouteListener "../dRouteListener";
import dRoutePublisher "../dRoutePublisher";

actor Self{



    let recievedEvents : Buffer.Buffer<DRouteTypes.DRouteEvent> = Buffer.Buffer<DRouteTypes.DRouteEvent>(16);


    public shared func test() : async {#success; #fail : Text} {
        Debug.print("running tests for publisher");


        let suite = S.suite("test publisher", [
                    S.test("testSimpleNotify", switch(await testSimpleNotify()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    S.test("testSubscribe", switch(await testSubscribe()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true)))
                ]);
        S.run(suite);



        return #success;

    };


    public shared func testSimpleNotify() : async {#success; #fail : Text} {
        Debug.print("running testSimpleNotify");

        let dRoutePub = dRoutePublisher.dRoutePublisher();

        let event = {
            eventType = "test123";
            userID = 1;
            dataConfig = #dataIncluded{
                data = [(0,0,[1:Nat8,2:Nat8,3:Nat8,4:Nat8])]};

        };

        Debug.print(debug_show(event));


        let result = await dRoutePub.publish(event);

        let regCanister : DRouteTypes.RegCanisterActor = actor(Principal.toText(dRoutePub.regPrincipal));
        let regResult = await regCanister.getEventRegistration(event.eventType);

        switch(result, regResult){
            case(#ok(result), ?regResult){
                Debug.print("running suite" # debug_show(result));

                let suite = S.suite("test simpleNotify", [
                    S.test("id exists", result.dRouteID, M.anything<Int>()),
                    S.test("time exists", result.timeRecieved, M.anything<Int>()),
                    S.test("status is recieved", switch(result.status){case(#recieved){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    S.test("processor is handling canister", Principal.toText(result.publishCanister) : Text, M.equals<Text>(T.text(Principal.toText(dRoutePub.regPrincipal)))),

                    ///test that the event was auto registerx
                    S.test("registration text should match", regResult.eventType : Text, M.equals<Text>(T.text("test123" : Text))),
                    S.test("valid sources should be this canister since it sent the first object", switch(regResult.validSources){case(#whitelist(list)){list[0] == Principal.fromActor(Self)};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    S.test("publishing canister should be the reg canister until we implement dynamic allocation", regResult.publishingCanisters[0] == Principal.toText(dRoutePub.regPrincipal), M.equals<Bool>(T.bool(true)))
                ]);

                S.run(suite);

                return #success;
            };
            case(#err(err), _){
                Debug.print("an error " # debug_show(result));
                return #fail(err.text);
            };
            case(_, null){
                Debug.print("an error registration was null");
                return #fail("an error registration was null");
            };
        };


    };

    public func __dRouteNotify(event: DRouteTypes.DRouteEvent) : async DRouteTypes.NotifyResponse{
        recievedEvents.add(event);
        return #ok(true);
    };

    public func __dRouteSubValidate(principal : Principal.Principal, userID: Nat) : async (Bool, Blob, DRouteTypes.MerkleTreeWitness){

        return (true, Blob.fromArray([1:Nat8]), #empty);
    };

    public shared func testSubscribe() : async {#success; #fail : Text} {
        Debug.print("running testSubscribe");

        let dRouteList  = dRouteListener.dRouteListener();

        let eventSub : DRouteTypes.SubscriptionRequest = {
            eventType = "test123";
            filter : ?DRouteTypes.SubscriptionFilter = null;
            throttle: ?DRouteTypes.SubscriptionThrottle = null;
            destinationSet = [Principal.fromActor(Self)];//send notifications to this canister
            userID = 1;
        };

        Debug.print(debug_show(eventSub));


        let result = await dRouteList.subscribe(eventSub);

        let pubCanister : DRouteTypes.PublishingCanisterActor = actor(Principal.toText(dRouteList.regPrincipal));


        let pubResult = await pubCanister.publish({
            eventType = "test123";
            userID = 2;
            dataConfig = #dataIncluded{
            data = [(0,0,[1:Nat8,2:Nat8,3:Nat8,4:Nat8])]};
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

        switch(result){
            case(#ok(result)){
                Debug.print("running suite" # debug_show(result));

                let suite = S.suite("test subscribe", [
                    S.test("subscription id exists", result.subscriptionID, M.anything<Int>()),
                    //todo test the signature

                    ///test that the event was auto registerx
                    S.test("message was recived", bMessageDelivered : Bool, M.equals<Bool>(T.bool(true)))
                ]);

                S.run(suite);

                return #success;
            };
            case(#err(err)){
                Debug.print("an error " # debug_show(result));
                return #fail(err.text);
            };

        };


    };




};