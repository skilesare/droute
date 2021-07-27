import RegCanister "canister:droute";
import UtilityTestCanister "canister:test_runner_droute_utilities";
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import Debug "mo:base/Debug";

actor {
    let it = C.Tester({ batchSize = 8 });
    public shared func test() : async Text {



        it.should("run utility tests", func () : async C.TestResult = async {
          let utilityResult = await UtilityTestCanister.test();
          Debug.print("result");
          Debug.print(debug_show(utilityResult));
          //M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
          return utilityResult;
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