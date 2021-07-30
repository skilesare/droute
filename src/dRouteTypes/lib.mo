///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import String "mo:base/Text";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat16 "mo:base/Nat16";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import TrixTypes "../trixTypes/lib";
import PipelinifyTypes "mo:pipelinify/pipelinify/PipelinifyTypes";
import MerkleTree "../dRouteUtilities/MerkleTree";

module {

    public type MerkleTree = MerkleTree.Tree;
    public type MerkleTreeKey = MerkleTree.Key;
    public type MerkleTreeVal = MerkleTree.Value;
    public type MerkleTreeWitness = MerkleTree.Witness;

    public type DRouteEvent = {
        eventType : Text;
        source : Principal;
        dataConfig : PipelinifyTypes.DataConfig;
        dRouteID: Nat;
        userID: Nat;
        //todo
        //certification: {
        //    #signature;
        //    #witness:{
        //        canister: Principal;
        //        witness: Blob;
        //    };
        //    #none;
        //};
    };

    //field 0 : name - text
    //field 1 : source - principal
    //field n-2...data
    public type DRouteEventStable = [TrixTypes.AddressedChunk];

    public type ValidSourceOptions = {
        #whitelist: [Principal];
        #blacklist: [Principal];
        #dynamic: {
            canister: Text;
        };
    };


    public type EventRegistration = {
        eventType: Text;
        var validSources: ValidSourceOptions;
        var publishingCanisters: [Text];
    };

    public type EventRegistrationStable = {
        eventType: Text;
        validSources: ValidSourceOptions;
        publishingCanisters: [Text];
    };

    public type NamespaceRight = {
        namespace: Text;
        controllers: [Principal];
        authorized: [Principal];
    };

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
        userID: Nat;
        dataConfig: PipelinifyTypes.DataConfig;
    };

    public type PublishStatus = {
        #recieved;
        #delivered;
    };

    public type PublishResponse = {
        dRouteID : Nat;
        timeRecieved : Int;
        status: PublishStatus;
        publishCanister : Principal.Principal;
    };

    public type PublishError = {
        code : Nat;
        text : Text;
    };


    public type ConfirmEventRegistrtationResponse = {
        #notFound;
        #found: DRouteEventDef;
    };



    public type SubscriptionFilter = {
        #notImplemented;
    };

    public type SubscriptionThrottle = {
        #notImplemented;
    };

    public type SubscriptionRequest = {

        eventType : Text;
        filter: ?SubscriptionFilter;
        throttle: ?SubscriptionThrottle;
        destinationSet: [Principal];
        userID: Nat; //hash of namespace to keep from duplicates from occuring

    };

    public type Subscription = {

        eventType : Text;
        filter: ?SubscriptionFilter;
        throttle: ?SubscriptionThrottle;
        destinationSet: [Principal];
        userID: Nat; //hash of namespace to keep from duplicates from occuring
        dRouteID: Nat;
        status: {
            #started;
            #stopped;
        };
        controllers: [Principal];
    };

    public type SubscriptionResponse = {
        subscriptionID: Nat;
        userID: Nat;
    };

    public type NotifyResponse = Result.Result<Bool, PublishError>;

    public type ProcessQueueResponse= {
        eventsProcessed: Nat;
        queueLength: Nat;
    };

    public type RegCanisterActor = actor {
        getPublishingCanisters: (Nat) -> async [Text];
        getEventRegistration: (Text) -> async ?EventRegistrationStable;
        subscribe: (SubscriptionRequest) -> async Result.Result<SubscriptionResponse, PublishError>;
    };

    public type PublishingCanisterActor = actor {
        publish: (EventPublishable) -> async Result.Result<PublishResponse,PublishError>;
        processQueue: () -> async Result.Result<ProcessQueueResponse, PublishError>;
    };

    public type ListenerCanisterActor = actor {
        __dRouteNotify: (DRouteEvent) -> async Result.Result<NotifyResponse,PublishError>;
        __dRouteSubValidate: query (Principal, Nat) -> async (Bool, Blob, MerkleTreeWitness);
    };


    ////////////////////////
    //
    // Errors
    //
    // Subscriptions
    // 1 - No valid destinations in DestinationSet


};
