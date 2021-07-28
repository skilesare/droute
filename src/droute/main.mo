actor {
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };
};

/*
import dRouteTypes "types";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";

shared(msg) actor class(){

    stable var upgradeEventRegistration: [dRouteTypes.EventRegistration] = [];

    var registrationStore = HashMap.HashMap<Text, dRouteTypes.EventRegistration>(
        1,
        Text.equal,
        Text.hash
    );

    public  func test() : async Nat {
        return 1;
    };


};
*/
