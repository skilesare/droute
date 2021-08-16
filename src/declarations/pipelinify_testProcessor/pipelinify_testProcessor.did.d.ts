import type { Principal } from '@dfinity/principal';
export type AddressedChunk = [bigint, bigint, TrixValue];
export interface ChunkPush {
  'chunk' : ChunkResponse,
  'pipeInstanceID' : PipeInstanceID,
}
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
  'queryPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result__1>,
  'requestPipelinifyChunk' : (arg_0: ChunkRequest) => Promise<Result__1>,
}
export interface ExecutionConfig {
  'executionMode' : { 'manual' : null } |
    { 'onLoad' : null },
}
export type Hash = number;
export type PipeInstanceID = number;
export interface ProcessError { 'code' : bigint, 'text' : string }
export interface ProcessRequest {
  'executionConfig' : ExecutionConfig,
  'responseConfig' : ResponseConfig,
  'event' : [] | [string],
  'dataConfig' : DataConfig,
}
export type ProcessResponse = {
    'stepProcess' : {
      'status' : ProcessType,
      'pipeInstanceID' : PipeInstanceID,
    }
  } |
  {
    'intakeNeeded' : {
      'chunkMap' : Array<boolean>,
      'totalChunks' : bigint,
      'currentChunks' : bigint,
      'pipeInstanceID' : PipeInstanceID,
    }
  } |
  { 'outtakeNeeded' : { 'pipeInstanceID' : PipeInstanceID } } |
  { 'dataIncluded' : { 'payload' : Array<AddressedChunk> } };
export type ProcessType = { 'error' : null } |
  { 'parallel' : { 'stepMap' : Array<boolean>, 'steps' : bigint } } |
  { 'sequential' : bigint } |
  { 'unconfigured' : null };
export interface Processor {
  'process' : (arg_0: ProcessRequest) => Promise<Result>,
  'pushChunk' : (arg_0: ChunkPush) => Promise<Result>,
}
export interface Property {
  'value' : TrixValue,
  'name' : string,
  'immutable' : boolean,
}
export interface ResponseConfig {
  'responseMode' : { 'pull' : null } |
    { 'push' : null },
}
export type Result = { 'ok' : ProcessResponse } |
  { 'err' : ProcessError };
export type Result__1 = { 'ok' : ChunkResponse } |
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
  { 'Text' : string } |
  { 'Bytes' : { 'thawed' : Array<number> } | { 'frozen' : Array<number> } } |
  { 'Int16' : number } |
  { 'Int32' : number } |
  { 'Int64' : bigint } |
  { 'Float' : number } |
  { 'Principal' : Principal } |
  { 'Class' : Array<Property> };
export interface _SERVICE extends Processor {}