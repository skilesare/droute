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
import PipelinifyTypes "mo:pipelinify/pipelinify/PipelinifyTypes";
import TrixTypes "../TrixTypes/lib";

module {

    //Types

    public type DRouteEventDef = {
        eventName: Text;
        validSources: {
            #whitelist: [Principal];
            #blacklist: [Principal];
            #dynamic: {
                canister: Text;
            };
        };
    };

    public type DRouteInitialization = {
        regCanister : ?Principal;
        eventTypes: [DRouteEventDef];
    };





    public type EventPublishable = {
        eventType: Text;
        dataConfig: PipelinifyTypes.DataConfig;
    };

    public type PublishStatus = {
        #recieved;
        #delivered;
    };

    public type PublishResponse = {
        id : Nat64;
        timeProcessed : Int;
        status: PublishStatus;
    };

    public type PublishError = {
        code : Nat;
        text : Text;
    };

    public class dRoutePublisher(){
        type Result<T,E> = Result.Result<T,E>;

        func selfHash(_self : Hash.Hash) : Hash.Hash {
            _self;
        };

        public func ensureRegistration(def : DRouteEventDef){
            //check the local cache to see if the def is in it

            //if it is return true

            //if not, register it

            //update the cache
        };

        public func updateRegistration() {
            //pass in a complicated structure and call different functions on the reg canister to update the registration
            //keep in sync with local cache

        };

        public func syncRegistration(){
            //pull configs from the reg canister and sync them with the local cache.
        };


        public func register() {

        };

        public func publish(event : EventPublishable) : Result<PublishResponse, PublishError> {
            return #err({code=404;text="Not Implemented"});
        };


    };



};
