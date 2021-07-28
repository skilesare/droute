//import RegCanister "canister:droute";
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import S "mo:matchers/Suite";
import Principal "mo:base/Principal";
import TrixTypes "../trixtypes/lib";
import DrouteUtilities "../DRouteUtilities/lib";
import Nat8 "mo:base/Nat8";
import Debug "mo:base/Debug";
import Error "mo:base/Error";

actor Self{
    let it = C.Tester({ batchSize = 8 });





    public shared func test() : async {#success; #fail : Text} {


          try {
            let data = TrixTypes.fromAddressedChunks([
            (0,0,TrixTypes.nat16ToBytes(1:Nat16)),
            (0,1,TrixTypes.nat16ToBytes(2:Nat16)),
            (1,0,TrixTypes.nat16ToBytes(3:Nat16))]);


            let dRouteEvent = DrouteUtilities.createEvent(
              "com.test.construction",
              Principal.fromActor(Self),
              data);

            Debug.print("principal" # debug_show(Principal.fromActor(Self)));

            //Debug.print("input " # debug_show(dRouteEvent));


            let stableDRouteEvent = DrouteUtilities.toStableEvent(dRouteEvent);

            Debug.print("result " # debug_show(stableDRouteEvent));

            let stableTextField : Text = TrixTypes.bytesToText(stableDRouteEvent[0].2);

            let suite = S.suite("test Addresed Chunk Construction", [
              S.test("1", dRouteEvent.eventType : Text, M.equals<Text>(T.text(stableTextField : Text))),
              S.test("2", Principal.toText(dRouteEvent.source), M.equals(T.text(Principal.toText(TrixTypes.bytesToPrincipal(stableDRouteEvent[1].2))))),

              S.test("3", 2, M.equals<Nat>(T.nat(stableDRouteEvent[2].0))),
              S.test("4", 0, M.equals(T.nat(stableDRouteEvent[2].1))),
              S.test("5", dRouteEvent.data.get(0).get(0).toArray(), M.equals(T.array<Nat8>(T.nat8Testable, stableDRouteEvent[2].2))),

              S.test("6", 2, M.equals(T.nat(stableDRouteEvent[3].0))),
              S.test("7", 1, M.equals(T.nat(stableDRouteEvent[3].1))),
              S.test("8", dRouteEvent.data.get(0).get(1).toArray(), M.equals(T.array<Nat8>(T.nat8Testable, stableDRouteEvent[3].2))),

              S.test("9", 3, M.equals(T.nat(stableDRouteEvent[4].0))),
              S.test("10", 0, M.equals(T.nat(stableDRouteEvent[4].1))),
              S.test("11", dRouteEvent.data.get(1).get(0).toArray(), M.equals(T.array<Nat8>(T.nat8Testable, stableDRouteEvent[4].2))),

              //entire array should have lenth5
              S.test("12", true, M.equals(T.bool(stableDRouteEvent.size() == 5)))
            ]);

            S.run(suite);

            return #success;
          } catch(err) {
            //Debug.Print(debug_show(err));
            Debug.print("err  " # Error.message(err));
            return #fail(Error.message(err));
          }



        // await it.run()
    }
}