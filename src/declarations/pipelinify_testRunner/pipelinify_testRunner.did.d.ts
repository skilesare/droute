import type { Principal } from '@dfinity/principal';
export type Result = { 'ok' : string } |
  { 'err' : string };
export interface pipelinify_runner { 'Test' : () => Promise<Result> }
export interface _SERVICE extends pipelinify_runner {}
