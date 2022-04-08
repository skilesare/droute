
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import Debug "mo:base/Debug";
import DRouteTypes "../dRouteTypes";
import DRouteUtilities "../dRouteUtilities";

import RegCanisterDef "../droute/main";
import UtilityTestCanisterDef "test_runner_droute_utilities";
import PublisherTestCanisterDef "test_publisher";


actor {
    let it = C.Tester({ batchSize = 8 });

    //this is annoying, but it is gets around the "not defined bug";
    let RegCanister : RegCanisterDef.DRoute = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");
    let UtilityTestCanister : UtilityTestCanisterDef.test_runner_droute_utilities = actor("rrkah-fqaaa-aaaaa-aaaaq-cai");
    let PublisherTestCanister : PublisherTestCanisterDef.test_publisher = actor("renrk-eyaaa-aaaaa-aaada-cai");
    
    public shared func test() : async Text {



        it.should("run utility tests", func () : async C.TestResult = async {
          let result = await UtilityTestCanister.test();
          Debug.print("result");
          Debug.print(debug_show(result));
          //M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
          return result;
        });


        it.should("run publisher tests", func () : async C.TestResult = async {
          let result = await PublisherTestCanister.test();
          Debug.print("result");
          Debug.print(debug_show(result));
          //M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
          return result;
        });

       

        /*
        it.should("notify function with included data", func () : async C.TestResult = async {
          let notification = await RegCanister.eventPublish({type = "com.test", data = #dataIncluded{}});
          M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
        });

        it.should("notify function with included data", func () : async C.TestResult = async {
          let notification = await RegCanister.eventPublish({type = "com.test", data = #dataIncluded{}});
          M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
        });
        */

        //todo: test notify function with pull specification
        //todo: test notify function with pullquery specification
        //todo: test notify function with push specification



        await it.runAll()
        // await it.run()
    }
}