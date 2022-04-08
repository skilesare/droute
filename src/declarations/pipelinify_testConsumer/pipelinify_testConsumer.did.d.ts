import type { Principal } from '@dfinity/principal';
export type AddressedChunk = [bigint, bigint, TrixValue];
export interface ChunkRequest {
  'sourceIdentifier' : [] | [Hash],
  'chunkID' : bigint,
  'event' : [] | [string],
}
export type ChunkResponse = { 'eof' : Array<AddressedChunk> } |
  { 'err' : ProcessError } |
  { 'chunk' : Array<AddressedChunk> } |
  { 'parallel' : [bigint, bigint, Array<AddressedChunk>] };
export interface Consumer {
  'queryPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
  'requestPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
  'testFullDataSendProcess' : (arg_0: Array<AddressedChunk>) => Promise<
      Array<AddressedChunk>
    >,
  'testPullChunkProcess' : () => Promise<Array<AddressedChunk>>,
  'testPullChunkUnknownProcess' : () => Promise<Array<AddressedChunk>>,
  'testPullFullProcess' : () => Promise<Array<AddressedChunk>>,
  'testPullFullQueryResponse' : () => Promise<Array<AddressedChunk>>,
  'testPushFullResponse' : () => Promise<Array<AddressedChunk>>,
}
export type Hash = number;
export interface ProcessError { 'code' : bigint, 'text' : string }
export interface Property {
  'value' : TrixValue,
  'name' : string,
  'immutable' : boolean,
}
export type Result = { 'ok' : ChunkResponse } |
  { 'err' : ProcessError };
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
  { 'Nats' : { 'thawed' : Array<bigint> } | { 'frozen' : Array<bigint> } } |
  { 'Text' : string } |
  { 'Bytes' : { 'thawed' : Array<number> } | { 'frozen' : Array<number> } } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Option' : [] | [TrixValue] } |
  { 'Floats' : { 'thawed' : Array<number> } | { 'frozen' : Array<number> } } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  {
    'Array' : { 'thawed' : Array<TrixValue> } |
      { 'frozen' : Array<TrixValue> }
  } |
  { 'Class' : Array<Property> };
export interface _SERVICE extends Consumer {}
