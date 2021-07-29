import type { Principal } from '@dfinity/principal';
export type AddressedChunk = [bigint, bigint, Array<number>];
export interface ChunkRequest {
  'sourceIdentifier' : [] | [Hash],
  'chunkID' : bigint,
  'event' : [] | [string],
}
export type ChunkResponse = { 'eof' : Array<AddressedChunk> } |
  { 'err' : ProcessError } |
  { 'chunk' : Array<AddressedChunk> } |
  { 'parallel' : [bigint, bigint, Array<AddressedChunk>] };
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
  'queryPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
  'requestPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
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
export interface PublishError { 'code' : bigint, 'text' : string }
export interface PublishResponse {
  'status' : PublishStatus,
  'dRouteID' : bigint,
  'timeRecieved' : bigint,
  'publishCanister' : Principal,
}
export type PublishStatus = { 'recieved' : null } |
  { 'delivered' : null };
export type Result = { 'ok' : ChunkResponse } |
  { 'err' : ProcessError };
export type Result__1 = { 'ok' : PublishResponse } |
  { 'err' : PublishError };
export type ValidSourceOptions = { 'blacklist' : Array<Principal> } |
  { 'whitelist' : Array<Principal> } |
  { 'dynamic' : { 'canister' : string } };
export interface _SERVICE {
  'getEventRegistration' : (arg_0: string) => Promise<
      [] | [EventRegistrationStable]
    >,
  'getPublishingCanisters' : (arg_0: bigint) => Promise<Array<string>>,
  'publish' : (arg_0: EventPublishable) => Promise<Result__1>,
}