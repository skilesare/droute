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

module {

    public type DRouteEvent = {
        eventType : Text;
        source : Principal;
        dataConfig : PipelinifyTypes.DataConfig;
        dRouteID: Nat;
        userID: Nat;
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

    public type RegCanisterActor = actor {
        getPublishingCanisters: (Nat) -> async [Text];
        getEventRegistration: (Text) -> async ?EventRegistrationStable;
    };

    public type PublishingCanisterActor = actor {
        publish: (EventPublishable) -> async Result.Result<PublishResponse,PublishError>;
    };


};
