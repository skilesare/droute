import DRouteTypes "../DRouteTypes";
import DRouteUtilities "../DRouteUtilities";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import List "mo:base/List";
import Time "mo:base/Time";


actor Self{

    //Types
    type EventPublishable = DRouteTypes.EventPublishable;
    type PublishResponse = DRouteTypes.PublishResponse;
    type PublishError = DRouteTypes.PublishError;
    type EventRegistration = DRouteTypes.EventRegistration;
    type ValidSourceOptions = DRouteTypes.ValidSourceOptions;

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


    public shared func getPublishingCanisters(instances : Nat) : async [Text] {
        //todo: need to allocate and produce requested instances. See US 29.
        return [Principal.toText(Principal.fromActor(Self))];
    };

    /////////////////////////////////////////
    //todo: probably needs to be moved to a different class for the PublishingCanister Class
    //keep below chunk seperated to move to a different canister
    ////////////////////////////////////////

    stable var processQueue: List.List<DRouteTypes.DRouteEvent> = List.nil<DRouteTypes.DRouteEvent>();
    stable var nonce : Nat = 0;

    public func getEventRegistration(eventType : Text) : async ?DRouteTypes.EventRegistrationStable{
        //this should query back to the reg canister if not in the local store;
        switch(registrationStore.get(eventType)){
            case(null){null};
            case(?registration){?DRouteUtilities.eventRegistrationToStable(registration)};
        };
    };

    public shared(msg) func publish(event : EventPublishable) : async Result.Result<PublishResponse,PublishError> {
        //make sure that this publisher can publish to this publication canister
        //todo: check if this is a private canister and/or if the user is authenticated to this shared canister

        //confirm registration of the event
        let eventRegistration = registrationStore.get(event.eventType);
        Debug.print("looking for Reg");
        let foundEventRegistration = switch(eventRegistration){
            case(null){
                Debug.print("reg is null");
                //this registration does not exist, register it with the defaults
                let defaultRegistration = {
                    eventType : Text = event.eventType;
                    var validSources : ValidSourceOptions = #whitelist([msg.caller]);
                    var publishingCanisters = [Principal.toText(Principal.fromActor(Self))];
                };
                registrationStore.put(event.eventType, defaultRegistration);

                defaultRegistration;
            };
            case(?registration){
                registration;

            };
        };

        Debug.print("found reg" # debug_show(foundEventRegistration));

        //check the principal sending the event against the registration
        var validController = false;
        switch(foundEventRegistration.validSources){
            case(#whitelist(list)){
                label checkList for(thisItem in list.vals()){
                    Debug.print(debug_show(thisItem) # " " #  debug_show(Principal.fromActor(Self)));
                    if(thisItem == msg.caller){
                        Debug.print("matches");
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

        //create an unique id
        let thisEventID = DRouteUtilities.generateEventID({
            eventType = event.eventType;
            source = msg.caller;
            userID = event.userID;
            nonce = nonce;});
        nonce += 1;

        let thisEvent = {
            eventType = event.eventType;
            source = msg.caller;
            userID = event.userID;
            dRouteID = thisEventID;
            dataConfig = event.dataConfig;
            timeRecieved = Time.now();
        };

        processQueue := List.push(thisEvent, processQueue);

        return #ok({
            dRouteID = thisEvent.dRouteID;
            timeRecieved = thisEvent.timeRecieved;
            status = #recieved;
            publishCanister = Principal.fromActor(Self);
        });


       return #err({code=404;text="Not Implemented"});
    };
};

/*
import DRouteTypes "types";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";

shared(msg) actor class(){

    stable var upgradeEventRegistration: [DRouteTypes.EventRegistration] = [];

    var registrationStore = HashMap.HashMap<Text, DRouteTypes.EventRegistration>(
        1,
        Text.equal,
        Text.hash
    );

    public  func test() : async Nat {
        return 1;
    };


};
*/
