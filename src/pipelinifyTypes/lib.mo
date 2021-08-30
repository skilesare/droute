///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import String "mo:base/Text";
import Text "mo:base/Text";

import TrixTypes "../trixTypes/lib";


module {

    type Hash = Hash.Hash;
    type Result<T,E> = Result.Result<T,E>;

    public type PipeInstanceID = Hash.Hash;

    public type AddressedChunk = TrixTypes.AddressedChunk;
    public type Workspace = TrixTypes.Workspace;

    public type DataChunk = Buffer.Buffer<Nat8>;
    public type DataZone = Buffer.Buffer<DataChunk>;




    //pipeline types
    public type PipelinifyIntitialization = {
        onDataWillBeLoaded: ?((Hash, ?ProcessRequest) -> PipelineEventResponse);
        onDataReady: ?((Hash, Workspace, ?ProcessRequest) -> PipelineEventResponse);
        onPreProcess: ?((Hash, Workspace, ?ProcessRequest, ?Nat) -> PipelineEventResponse);
        onProcess: ?((Hash, Workspace, ?ProcessRequest, ?Nat) -> PipelineEventResponse);
        onPostProcess: ?((Hash, Workspace, ?ProcessRequest, ?Nat) -> PipelineEventResponse);
        onDataWillBeReturned: ?((Hash, Workspace,?ProcessRequest) -> PipelineEventResponse);
        onDataReturned: ?((Hash, ?ProcessRequest, ?ProcessResponse) -> PipelineEventResponse);
        getProcessType: ?((Hash, Workspace, ?ProcessRequest) -> ProcessType);
        getLocalWorkspace: ?((Hash, Nat, ?ProcessRequest) -> TrixTypes.Workspace);
        putLocalWorkspace: ?((Hash, Nat, TrixTypes.Workspace, ?ProcessRequest) -> TrixTypes.Workspace);

    };

    public type ChunkResponse = {
        #chunk: [AddressedChunk];
        #eof: [AddressedChunk];
        #parallel: (Nat, Nat,[AddressedChunk]);
        #err: ProcessError;
    };

    public type ChunkPush = {
        pipeInstanceID: PipeInstanceID;
        chunk: ChunkResponse;
    };

    public type StepRequest = {
        pipeInstanceID: PipeInstanceID;
        step: ?Nat;
    };

    public type DataConfig  = {
        #dataIncluded : {
            data: [AddressedChunk]; //data if small enough to fit in the message
        };
        #local : Nat;

        #pull : {
            sourceActor: ?DataSource;
            sourceIdentifier: ?Hash.Hash;
            mode : { #pull; #pullQuery;};
            totalChunks: ?Nat32;
            data: ?[AddressedChunk];
        };
        #push;
        #internal;
    };


    public type ProcessRequest = {
        event: ?Text;
        dataConfig: DataConfig;
        executionConfig: ExecutionConfig;
        responseConfig: ResponseConfig;
    };

    public type RequestCache = {
        request : ProcessRequest;
        timestamp : Nat;
        status: {
            #initialized;
            #dataDone;
            #responseReady;
            #finalized;
        };
    };

    public type ProcessCache = {
        map : [var Bool];
        steps : Nat;
        var status: {
            #initialized;
            #done;
            #pending: Nat;
        };
    };

    public type ExecutionConfig = {
        executionMode: {
                #onLoad;
                #manual;
            };
    };

    public type ResponseConfig = {
        responseMode: {
                #push;
                #pull;
                #local : Nat;
            };
    };

    public type ProcessError = {
        text: Text;
        code: Nat;
    };


    public type ProcessResponse = {
        #dataIncluded: {
            payload: [AddressedChunk];
        };
        #local : Nat;
        #intakeNeeded: {
            pipeInstanceID: PipeInstanceID;
            currentChunks: Nat;
            totalChunks: Nat;
            chunkMap: [Bool];
        };
        #outtakeNeeded: {
            pipeInstanceID: PipeInstanceID;
        };
        #stepProcess: {
            pipeInstanceID: PipeInstanceID;
            status: ProcessType;
        };

    };

    public type DataReadyResponse = {
        #dataIncluded: {
            payload: [AddressedChunk];
        };
        #error: {
            text: Text;
            code: Nat;
        };
    };

    public type PipelineEventResponse = {
        #dataNoOp;
        #dataUpdated;
        #stepNeeded;
        #error : ProcessError;
    };

    public type WorkspaceCache = {
        var status : {
            #initialized;
            #loading: (Nat,Nat,[Bool]); //(chunks we've seen, totalChunks, map of recieved items)
            #doneLoading;
            #processing: Nat;
            #doneProcessing;
            #returning: Nat;
            #done
        };
        data: Workspace;
    };



    public type ChunkRequest = {
        chunkID: Nat;
        event: ?Text;
        sourceIdentifier: ?Hash.Hash;
    };

    public type ChunkGet = {
        chunkID: Nat;
        chunkSize: Nat;
        pipeInstanceID: PipeInstanceID;
    };

    public type PushStatusRequest = {
        pipeInstanceID: PipeInstanceID;
    };
    public type ProcessingStatusRequest = {
        pipeInstanceID: PipeInstanceID;
    };

    public type DataSource = actor {
        requestPipelinifyChunk : (_request : ChunkRequest) -> async Result<ChunkResponse,ProcessError>;
        queryPipelinifyChunk : query (_request : ChunkRequest) -> async Result<ChunkResponse,ProcessError>;
    };

    public type ProcessActor = actor {
        process : (_request : ProcessRequest) -> async Result<ProcessResponse,ProcessError>;
        getChunk : (_request : ChunkGet) -> async Result<ChunkResponse,ProcessError>;
        pushChunk: (_request: ChunkPush) -> async Result<ProcessResponse,ProcessError>;
        getPushStatus: query (_request: PushStatusRequest) -> async Result<ProcessResponse,ProcessError>;
        getProcessingStatus: query (_request: ProcessingStatusRequest) -> async Result<ProcessResponse,ProcessError>;
        singleStep: (_request: StepRequest) -> async Result<ProcessResponse,ProcessError>;
    };


    public type PushToPipeStatus = {#pending : Nat; #finished; #err: ProcessError;};
    public type ProcessingStatus = {#pending : (Nat, Nat); #finished; #err: ProcessError;};

    public type ProcessType = {
        #unconfigured;
        #error;
        #sequential: Nat;
        #parallel: {
            stepMap: [Bool];
            steps: Nat;
        };

    };






    //error list
    //
    // Intake push errors
    // 8 - cannot find intake cache for provided id
    // 9 - Cannot add to a 'done' intake cache
    // 10 - Do not send an error chunk type to the intake process
    // 11 - Unloaded Intake Cache. Should Not Be Here.
    // 12 - Request cache is missing.
    // 16 - Do not send an error chunk

    // GetChunk errors
    // 13 -- cannot find response cache

    //pushChunk
    // 14 -- parallel - pipe already pushed
    // 15 -- done loading

    //pushChunk Status
    //17 -- Pipe is not in intake state

    //single step
    //19 -- error with step
    //20 -- map missing
    //21 -- processing not ready
    //22 -- done processing



};
