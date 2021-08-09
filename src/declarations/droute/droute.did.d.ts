import type { Principal } from '@dfinity/principal';
export type AddressedChunk = [bigint, bigint, Array<number>];
export type AddressedChunkArray = Array<[bigint, bigint, Array<number>]>;
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
      'lastMarker' : [] | [bigint],
    }
  } |
  { 'pointer' : { 'canister' : Principal } };
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
export type ValidSourceOptions = { 'blacklist' : Array<Principal> } |
  { 'whitelist' : Array<Principal> } |
  { 'dynamic' : { 'canister' : string } };
export interface _SERVICE extends DRoute {}