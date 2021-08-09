//import RegCanister "canister:droute";
//import UtilityTestCanister "canister:test_runner_droute_utilities";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import C "mo:matchers/Canister";
import DRouteTypes "../DRouteTypes/lib";
import DRouteUtilities "../DRouteUtilities/lib";
import Debug "mo:base/Debug";
import M "mo:matchers/Matchers";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Array "mo:base/Array";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import TrixTypes "../TrixTypes/lib";
import NIsp "../nisp/main";


import ExperimentalCycles "mo:base/ExperimentalCycles";

actor class test_publisher() = this{

    let nispActor : NIsp.NIsp = actor("qoctq-giaaa-aaaaa-aaaea-cai");
    stable var nonce : Nat = 0;

  public shared func test() : async {#success; #fail : Text} {
        Debug.print("running tests for nisp");


        let suite = S.suite("test nisp", [
                    //test getting witness returns empty if no witness
                    S.test("testGetWitnessEmpty", switch(await testGetWitnessEmpty()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    S.test("testGetWitnessSubscribed", switch(await testGetWitnessSubscribed()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    //test getting witness when member exists
                    //test getting witness when user has blocked the application
                ]);
        S.run(suite);



        return #success;

    };

    public shared func testGetWitnessEmpty() : async {#success; #fail : Text} {
        Debug.print("running testGetWitnessEmpty");
        let principal = Principal.fromActor(this);

        let result = await nispActor.getStatus();


        switch(result){
            case(#ok(result)){
                Debug.print("running suite" # debug_show(result));

                let suite = S.suite("test testGetWitnessEmpty ok", [

                    S.test("status is not registered", switch(result){case(#notFound(aResult)){true};case(_){false};}, M.equals<Bool>(T.bool(true)))
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

    public shared func testGetWitnessSubscribed() : async {#success; #fail : Text} {
        Debug.print("running testGetWitnessSubscribed");
        let principal = Principal.fromActor(this);

        //add a balance for this witness
        let updateResult = await nispActor.updateCycles(principal, 1_000_000_000_000);


        //checkthe status

        let result = await nispActor.getStatus();


        switch(result){
            case(#ok(result)){
                Debug.print("running suite" # debug_show(result));

                let suite = S.suite("test testGetWitnessEmpty ok", [

                    S.test("status is found", switch(result){case(#cycleBalance(aResult)){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    S.test("status is found", switch(result){case(#cycleBalance(aResult)){aResult.0};case(_){404};}, M.equals<Nat>(T.nat(1_000_000_000_000))),
                    //todo: make sure the witness matches

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