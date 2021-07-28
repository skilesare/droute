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
  'dataConfig' : DataConfig,
  'eventType' : string,
}
export type Hash = number;
export interface ProcessError { 'code' : bigint, 'text' : string }
export interface PublishError { 'code' : bigint, 'text' : string }
export interface PublishResponse {
  'id' : bigint,
  'status' : PublishStatus,
  'timeProcessed' : bigint,
}
export type PublishStatus = { 'recieved' : null } |
  { 'delivered' : null };
export type Result = { 'ok' : ChunkResponse } |
  { 'err' : ProcessError };
export type Result__1 = { 'ok' : PublishResponse } |
  { 'err' : PublishError };
export interface _SERVICE {
  'getPublishingCanisters' : (arg_0: bigint) => Promise<Array<string>>,
  'publish' : (arg_0: EventPublishable) => Promise<Result__1>,
}