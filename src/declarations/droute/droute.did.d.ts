import type { Principal } from '@dfinity/principal';
export type AddressedChunk = [bigint, bigint, TrixValue];
export type AddressedChunkArray = Array<AddressedChunk__1>;
export type AddressedChunk__1 = [bigint, bigint, TrixValue__1];
export interface ChunkRequest {
  'sourceIdentifier' : [] | [Hash],
  'chunkID' : bigint,
  'event' : [] | [string],
}
export type ChunkResponse = { 'eof' : Array<AddressedChunk> } |
  { 'err' : ProcessError } |
  { 'chunk' : Array<AddressedChunk> } |
  { 'parallel' : [bigint, bigint, Array<AddressedChunk>] };
export interface DRoute {
  'getEventRegistration' : (arg_0: string) => Promise<
      [] | [EventRegistrationStable]
    >,
  'getProcessingLogs' : (arg_0: string) => Promise<ReadResponse>,
  'getProcessingLogsByIndex' : (arg_0: string, arg_1: bigint) => Promise<
      ReadResponse
    >,
  'getPublishingCanisters' : (arg_0: bigint) => Promise<Array<string>>,
  'processQueue' : () => Promise<Result_2>,
  'publish' : (arg_0: EventPublishable) => Promise<Result_1>,
  'subscribe' : (arg_0: SubscriptionRequest) => Promise<Result>,
}
export type DataConfig = { 'internal' : null } |
  {
    'pull' : {
      'sourceIdentifier' : [] | [Hash],
      'data' : [] | [Array<AddressedChunk>],
      'mode' : { 'pullQuery' : null } |
        { 'pull' : null },
      'sourceActor' : [] | [DataSource],
      'totalChunks' : [] | [number],
    }
  } |
  { 'push' : null } |
  { 'local' : bigint } |
  { 'dataIncluded' : { 'data' : Array<AddressedChunk> } };
export interface DataSource {
  'queryPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result__1>,
  'requestPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result__1>,
}
export interface Entry {
  'data' : AddressedChunkArray,
  'primaryID' : bigint,
  'marker' : bigint,
}
export interface EventPublishable {
  'userID' : bigint,
  'dataConfig' : DataConfig,
  'eventType' : string,
}
export interface EventRegistrationStable {
  'publishingCanisters' : Array<string>,
  'validSources' : ValidSourceOptions,
  'eventType' : string,
}
export type Hash = number;
export type Principal = Principal;
export interface ProcessError { 'code' : bigint, 'text' : string }
export interface ProcessQueueResponse {
  'queueLength' : bigint,
  'eventsProcessed' : bigint,
}
export interface Property {
  'value' : TrixValue,
  'name' : string,
  'immutable' : boolean,
}
export interface Property__1 {
  'value' : TrixValue__1,
  'name' : string,
  'immutable' : boolean,
}
export interface PublishError { 'code' : bigint, 'text' : string }
export interface PublishError__1 { 'code' : bigint, 'text' : string }
export interface PublishResponse {
  'status' : PublishStatus,
  'dRouteID' : bigint,
  'timeRecieved' : bigint,
  'publishCanister' : Principal,
}
export type PublishStatus = { 'recieved' : null } |
  { 'delivered' : null };
export type ReadResponse = {
    'data' : {
      'data' : Array<Entry>,
      'lastID' : [] | [bigint],
      'firstID' : [] | [bigint],
      'lastMarker' : [] | [bigint],
      'firstMarker' : [] | [bigint],
    }
  } |
  {
    'pointer' : {
      'maxID' : [] | [bigint],
      'minID' : [] | [bigint],
      'lastID' : bigint,
      'lastMarker' : bigint,
      'canister' : Principal,
      'namespace' : string,
    }
  } |
  { 'notFound' : null };
export type Result = { 'ok' : SubscriptionResponse } |
  { 'err' : PublishError };
export type Result_1 = { 'ok' : PublishResponse } |
  { 'err' : PublishError__1 };
export type Result_2 = { 'ok' : ProcessQueueResponse } |
  { 'err' : PublishError };
export type Result__1 = { 'ok' : ChunkResponse } |
  { 'err' : ProcessError };
export type SubscriptionFilter = { 'notImplemented' : null };
export interface SubscriptionRequest {
  'userID' : bigint,
  'filter' : [] | [SubscriptionFilter],
  'throttle' : [] | [SubscriptionThrottle],
  'destinationSet' : Array<Principal>,
  'eventType' : string,
}
export interface SubscriptionResponse {
  'userID' : bigint,
  'subscriptionID' : bigint,
}
export type SubscriptionThrottle = { 'notImplemented' : null };
export type TrixValue = { 'Int' : bigint } |
  { 'Nat' : bigint } |
  { 'Empty' : null } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Array<number> } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Nat8' : number } |
  { 'Text' : string } |
  { 'Bytes' : { 'thawed' : Array<number> } | { 'frozen' : Array<number> } } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Class' : Array<Property> };
export type TrixValue__1 = { 'Int' : bigint } |
  { 'Nat' : bigint } |
  { 'Empty' : null } |
  { 'Nat16' : number } |
  { 'Nat32' : number } |
  { 'Nat64' : bigint } |
  { 'Blob' : Array<number> } |
  { 'Bool' : boolean } |
  { 'Int8' : number } |
  { 'Nat8' : number } |
  { 'Text' : string } |
  { 'Bytes' : { 'thawed' : Array<number> } | { 'frozen' : Array<number> } } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Class' : Array<Property__1> };
export type ValidSourceOptions = { 'blacklist' : Array<Principal> } |
  { 'whitelist' : Array<Principal> } |
  { 'dynamic' : { 'canister' : string } };
export interface _SERVICE extends DRoute {}