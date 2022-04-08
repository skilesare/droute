import type { Principal } from '@dfinity/principal';
export type AddressedChunk = [bigint, bigint, CandyValue];
export type CandyValue = { 'Int' : bigint } |
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
  { 'Option' : [] | [CandyValue] } |
  { 'Floats' : { 'thawed' : Array<number> } | { 'frozen' : Array<number> } } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  {
    'Array' : { 'thawed' : Array<CandyValue> } |
      { 'frozen' : Array<CandyValue> }
  } |
  { 'Class' : Array<Property> };
export interface ChunkRequest {
  'sourceIdentifier' : [] | [Hash__1],
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
      'sourceIdentifier' : [] | [Hash__1],
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
  'queryPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
  'requestPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result>,
}
export type Hash = Array<number>;
export type Hash__1 = number;
export type Key = Array<number>;
export type MerkleTreeWitness = { 'labeled' : [Key, Witness] } |
  { 'fork' : [Witness, Witness] } |
  { 'leaf' : Value } |
  { 'empty' : null } |
  { 'pruned' : Hash };
export type NotifyResponse = { 'ok' : boolean } |
  { 'err' : PublishError };
export type Principal = Principal;
export interface ProcessError { 'code' : bigint, 'text' : string }
export interface Property {
  'value' : CandyValue,
  'name' : string,
  'immutable' : boolean,
}
export interface PublishError { 'code' : bigint, 'text' : string }
export type Result = { 'ok' : ChunkResponse } |
  { 'err' : ProcessError };
export type Value = Array<number>;
export type Witness = { 'labeled' : [Key, Witness] } |
  { 'fork' : [Witness, Witness] } |
  { 'leaf' : Value } |
  { 'empty' : null } |
  { 'pruned' : Hash };
export interface test_publisher {
  '__dRouteNotify' : (arg_0: DRouteEvent) => Promise<NotifyResponse>,
  '__dRouteSubValidate' : (arg_0: Principal, arg_1: bigint) => Promise<
      [boolean, Array<number>, MerkleTreeWitness]
    >,
  'test' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
  'testSimpleNotify' : () => Promise<
      { 'fail' : string } |
        { 'success' : null }
    >,
  'testSubscribe' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
}
export interface _SERVICE extends test_publisher {}
