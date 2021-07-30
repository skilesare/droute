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
export interface DRouteEvent {
  'source' : Principal,
  'userID' : bigint,
  'dataConfig' : DataConfig,
  'dRouteID' : bigint,
  'eventType' : string,
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
  'queryPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
  'requestPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
}
export type Hash = number;
export type NotifyResponse = { 'ok' : boolean } |
  { 'err' : PublishError };
export interface ProcessError { 'code' : bigint, 'text' : string }
export interface PublishError { 'code' : bigint, 'text' : string }
export type Result = { 'ok' : ChunkResponse } |
  { 'err' : ProcessError };
export type Result__1 = { 'ok' : NotifyResponse } |
  { 'err' : PublishError };
export interface _SERVICE {
  '__dRouteNotify' : (arg_0: DRouteEvent) => Promise<Result__1>,
  'test' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
  'testSimpleNotify' : () => Promise<
      { 'fail' : string } |
        { 'success' : null }
    >,
  'testSubscribe' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
}