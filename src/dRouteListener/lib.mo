///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Int "mo:base/Int";
import TrixTypes "../TrixTypes";
import Principal "mo:base/Principal";
//import RegCanister "../droute/main";
import dRouteTypes "../dRouteTypes";

module {

    //Types

    public type DRouteEventDef = dRouteTypes.DRouteEventDef;
    public type DRouteInitialization = dRouteTypes.DRouteInitialization;
    public type EventPublishable = dRouteTypes.EventPublishable;
    public type PublishStatus = dRouteTypes.PublishStatus;
    public type PublishResponse = dRouteTypes.PublishResponse;
    public type PublishError = dRouteTypes.PublishError;
    public type ConfirmEventRegistrtationResponse = dRouteTypes.ConfirmEventRegistrtationResponse;
    public type RegCanisterActor =  dRouteTypes.RegCanisterActor;
    public type PublishingCanisterActor =  dRouteTypes.PublishingCanisterActor;

    public class dRouteListener(){
        type Result<T,E> = Result.Result<T,E>;

        func selfHash(_self : Hash.Hash) : Hash.Hash {
            _self;
        };


        public func subscribe(event : EventPublishable) : async Result<PublishResponse, PublishError> {

            //check to see if we have a set of canisters to send messages to
            let RegCanister : RegCanisterActor = actor(Principal.toText(regPrincipal));

            Debug.print(debug_show(publishingCanisters.size()));
            if(publishingCanisters.size() == 0){
                Debug.print("syncing");
                let sync = await syncRegistration();
            };
            Debug.print(debug_show(Int.abs(Time.now())));
            Debug.print(debug_show(publishingCanisters));
            let targetCanister = publishingCanisters[Nat.rem(Int.abs(Time.now()), publishingCanisters.size())];
            //send the message to the pulication canister

            let publishingCanister : PublishingCanisterActor = actor(targetCanister);

            let publishResult = await publishingCanister.publish(event);

            switch publishResult{
                case(#ok(result)){
                    return publishResult;
                };
                case(#err(err)){
                    return #err(err);
                };
            };

            return #err({code=404;text="Not Implemented"});
        };


    };



};
