import dRouteTypes "../drouteTypes/lib";
import Principal "mo:base/Principal";
import Result "mo:base/Result";


actor Self{

    //Types
    type EventPublishable = dRouteTypes.EventPublishable;
    type PublishResponse = dRouteTypes.PublishResponse;
    type PublishError = dRouteTypes.PublishError;
    type EventRegistration = dRouteTypes.EventRegistration;


    public shared func getPublishingCanisters(instances : Nat) : async [Text] {
        //todo: need to allocate and produce requested instances. See US 29.
        return [Principal.toText(Principal.fromActor(Self))];
    };

    /////////////////////////////////////////
    //todo: probably needs to be moved to a different class for the PublishingCanister Class
    //keep below chunk seperated to move to a different canister
    ////////////////////////////////////////

    stable var upgradeEventRegistration: [dRouteTypes.EventRegistration] = [];

    var registrationStore = HashMap.HashMap<Text, dRouteTypes.EventRegistration>(
        1,
        Text.equal,
        Text.hash
    );

    func let getEventRegistration(eventType : Text) : ?EventRegistration{
        //this should query back to the reg canister
    };

    public shared(msg) func publish(event : EventPublishable) : async Result.Result<PublishResponse,PublishError> {
        //make sure that this publisher can publish to this publication canister
        //todo: check if this is a private canister and/or if the user is authenticated to this shared canister

        //confirm registration of the event
        let eventRegistration = getEventRegistration(event.eventType);
        let foundEventRegistration = switch(eventRegistration){
            case(null){
                //this registration does not exist, register it with the defaults
                let defaultRegistration = {
                    eventType = event.eventType;
                    var validSources = #whitelist([msg.sender]);
                    var publishingCanisters = [Principal.fromActor(Self)];
                };
                registrationStore.put(event.eventType, defaultRegistration);

                defaultRegistration;
            };
            case(?registration){
                return registration;

            };
        };

        //check the principal sending the event against the registration
        var validController = false;
        switch(foundEventRegistration.validSources){
            case(#whitelist(list)){
                label checkList for(thisItem in list){
                    if(thisItem == Principal.fromActor(Self)){
                        validController := true;
                        break checkList;
                    };
                };
            };
            case(#blacklist(list)){
                return #err({code=404;text="Not Implemented - black list"});
            };
            case(#dynamic(dynamicPath)){
                return #err({code=404;text="Not Implemented - dynamic "});
            };

        };

        if(validController == false){
            return #err({code=401;text="Not Authorized"});
        };

        //add the event to the queue

       return #err({code=404;text="Not Implemented"});
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
