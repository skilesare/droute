//import RegCanister "canister:droute";
//import UtilityTestCanister "canister:test_runner_droute_utilities";
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import S "mo:matchers/Suite";
import dRoutePublisher "../dRoutePublisher/lib";
import TrixTypes "../TrixTypes/lib";
import Debug "mo:base/Debug";

actor Self{


    public shared func test() : async {#success; #fail : Text} {
        Debug.print("running tests for publisher");


        let suite = S.suite("test publisher", [
                    S.test("testSimpleNotify", switch(await testSimpleNotify()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true)))
                ]);
        S.run(suite);



        return #success;

    };


    public shared func testSimpleNotify() : async {#success; #fail : Text} {
        Debug.print("running testSimpleNotify");

        let event = {
            eventType = "test123";
            dataConfig = #dataIncluded{
                data = [(0,0,[1:Nat8,2:Nat8,3:Nat8,4:Nat8])]};

        };

        Debug.print(debug_show(event));

        let result = dRoutePub.publish(event);

        switch(result){
            case(#ok(result)){
                Debug.print("running suite" # debug_show(result));

                let suite = S.suite("test simpleNotify", [
                    S.test("id exists", result.id, M.anything<Nat64>()),
                    S.test("time exists", result.timeProcessed, M.anything<Int>()),

                    S.test("status is recieved", switch(result.status){case(#recieved){true};case(_){false};}, M.equals<Bool>(T.bool(true)))
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


    let dRoutePub = dRoutePublisher.dRoutePublisher();

};