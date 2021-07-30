import DRouteTypes "../DRouteTypes";
import DRouteUtilities "../DRouteUtilities";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import List "mo:base/List";
import Time "mo:base/Time";
import Order "mo:base/Order";
import Heap "mo:base/Heap";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Hash "mo:base/Hash";


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


    var subscriptionStore = HashMap.HashMap<Text, HashMap.HashMap<Nat,DRouteTypes.Subscription>>(
            1,
            Text.equal,
            Text.hash
        );

    public shared(msg) func subscribe(subInit : DRouteTypes.SubscriptionRequest) : async Result.Result<DRouteTypes.SubscriptionResponse, DRouteTypes.PublishError>{

        //todo:check to see if the subscription qualifies for being added

        //todo: make sure the destination validate are authorized
        let validDestinations = Buffer.Buffer<Principal>(subInit.destinationSet.size());
        for(thisDestination in subInit.destinationSet.vals()){
            let aActor : DRouteTypes.ListenerCanisterActor = actor(Principal.toText(thisDestination));
            let aValidSub: (Bool, Blob, DRouteTypes.MerkleTreeWitness) = await aActor.__dRouteSubValidate(thisDestination, subInit.userID);
            if(aValidSub.0 == true){
                //todo: verify sub is part of root
                validDestinations.add(thisDestination);
            };
        };

        if(validDestinations.size() > 0){
            //check the hashmap to see if this subscription exists
            let subMap = switch(subscriptionStore.get(subInit.eventType)){
                case(null){
                    //if it does not exist then create the empty map
                    let aSubMap = HashMap.HashMap<Nat,DRouteTypes.Subscription>(1, Nat.equal, Hash.hash);
                    subscriptionStore.put(subInit.eventType, aSubMap);
                    aSubMap;
                };
                case(?aSubMap){aSubMap};
            };

            let dRouteID = DRouteUtilities.generateSubscriptionID({
                eventType = subInit.eventType;
                source = msg.caller;
                userID = subInit.userID;
                nonce = nonce;});
            nonce += 1;

            let sub = {
                eventType = subInit.eventType;
                filter = subInit.filter;
                throttle = subInit.throttle;
                destinationSet = validDestinations.toArray();
                userID = subInit.userID;
                dRouteID = dRouteID;
                //todo: handle starting and stopping from request
                status = #started;
                controllers = [msg.caller];
            };

            //Now that the buffer exists, push the subscription on
            subMap.put(subInit.userID, sub);

            return #ok({subscriptionID=dRouteID; userID = subInit.userID});

        } else {
            return(#err({code=1;text="No valid destinations in DestinationSet. Deploy destination canisters before subscribing."}))
        };
        //todo: push the subscription to any publishing canisters for this event

        return #err({code=404; text="not implemented subscribe"})
    };

    /////////////////////////////////////////
    //todo: probably needs to be moved to a different class for the PublishingCanister Class
    //keep below chunk seperated to move to a different canister
    ////////////////////////////////////////
    func broadcastOrder(x : DRouteTypes.Subscription, y :  DRouteTypes.Subscription) : Order.Order{
        //todo: convert this to staked tokens
        if(x.userID > y.userID){
            return #greater;
        } else if (x.userID < y.userID){
            return #less;
        } else {
            return #equal;
        };
    };

    stable var pendingQueue: List.List<DRouteTypes.DRouteEvent> = List.nil<DRouteTypes.DRouteEvent>();
    stable var upgradePendingHeap: Heap.Tree<DRouteTypes.Subscription> = null;
    var pendingHeap: Heap.Heap<DRouteTypes.Subscription> = Heap.Heap<DRouteTypes.Subscription>(broadcastOrder);

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

        pendingQueue := List.push(thisEvent, pendingQueue);

        return #ok({
            dRouteID = thisEvent.dRouteID;
            timeRecieved = thisEvent.timeRecieved;
            status = #recieved;
            publishCanister = Principal.fromActor(Self);
        });


       //return #err({code=404;text="Not Implemented"});
    };

    public func processQueue() : async Result.Result<DRouteTypes.ProcessQueueResponse, DRouteTypes.PublishError>{
        //todo: see if there are events in the queue - we always get the first event
        var thisEvent : ?DRouteTypes.DRouteEvent = List.last<DRouteTypes.DRouteEvent>(pendingQueue);
        switch(thisEvent){
            case(null){
                //there are no events in the queue to be procesed
                return #ok({eventsProcessed = 0;
                queueLength = 0;});
            };
            case(?thisEvent){
                var currentHeap : Heap.Heap<DRouteTypes.Subscription> = switch(pendingHeap.peekMin()){
                    case(null){
                        //there is nothing in the heap, lets fill it up

                        //todo: see if there are subscriptions

                        //todo: the following function should apply any filters and throttles
                        //todo: create a heap of subscription calls
                        let heapResult = buildSubscriptionsHeap(thisEvent.eventType);
                        //todo: handle what to do if there are too many subscriptions
                        pendingHeap := heapResult;

                        pendingHeap;

                    };
                    case(?item){
                        pendingHeap;
                    };
                };


                switch(currentHeap.peekMin()){
                    case(null){
                        //there is nothing in the heap, we don't have anything to do

                        //.the last item must be done or have no subscriptions and was abandoned, so lets remove it
                        pendingQueue := List.take<DRouteTypes.DRouteEvent>(pendingQueue, List.size<DRouteTypes.DRouteEvent>(pendingQueue)-1);

                        return #ok({eventsProcessed = 0;
                        queueLength = List.size<DRouteTypes.DRouteEvent>(pendingQueue);});
                    };
                    case(?item){
                        //lets process the heap!
                        var itemsProcessed = 0;

                        label doHeap while(1==1){


                            let thisSub = pendingHeap.removeMin();
                            switch(thisSub){
                                case(null){
                                    //we are done
                                    break doHeap;
                                };
                                case(?thisSub){
                                    let aActorPrincipal = if(thisSub.destinationSet.size() > 0){
                                        thisSub.destinationSet[0];
                                    } else {
                                        thisSub.destinationSet[Nat.rem(Int.abs(Time.now()) + itemsProcessed, thisSub.destinationSet.size())];
                                    };
                                    let aActor : DRouteTypes.ListenerCanisterActor = actor(Principal.toText(aActorPrincipal));
                                    Debug.print("in processing" # debug_show(thisEvent.userID));
                                    let response = aActor.__dRouteNotify(thisEvent);


                                };
                            };

                            itemsProcessed += 1;
                            //todo figure out handbreak
                            if(itemsProcessed > 10000){
                                break doHeap;
                            };


                        };

                        //take the last item off the pending eventlist
                        //todo: if we haven't fiished then we need to save the event the heap is currenlty processing
                        pendingQueue := List.take<DRouteTypes.DRouteEvent>(pendingQueue, List.size<DRouteTypes.DRouteEvent>(pendingQueue)-1);

                        return #ok({
                            eventsProcessed = itemsProcessed;
                            queueLength = List.size<DRouteTypes.DRouteEvent>(pendingQueue);
                        });

                    };
                };
            };
        };



        //loop through pending heap and send messages.
        //remove item from the processing queue
        return #err({code=404; text="not implemented subscribe"})
    };

    func buildSubscriptionsHeap(eventType : Text) : Heap.Heap<DRouteTypes.Subscription>{
        let thisHeap = Heap.Heap<DRouteTypes.Subscription>(broadcastOrder);
        let aMap = subscriptionStore.get(eventType);
        switch(aMap){
            case(null){
                return thisHeap;
            };
            case(?aMap){
                for((thisKey,thisSub) in aMap.entries()){
                    thisHeap.put(thisSub);
                };
                return thisHeap;
            };
        };

    };

    system func preupgrade() {

        upgradePendingHeap := pendingHeap.share()
    };

    system func postupgrade() {
        pendingHeap.unsafeUnshare(upgradePendingHeap);
        upgradePendingHeap := null;
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
