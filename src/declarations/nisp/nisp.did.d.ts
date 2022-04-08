import type { Principal } from '@dfinity/principal';
export type GetStatusResponse = { 'cycleBalance' : [bigint, Witness] } |
  { 'pointer' : [Principal, Witness] } |
  { 'notFound' : Witness };
export type Hash = Array<number>;
export type Key = Array<number>;
export interface NIsp {
  '__resetTest' : () => Promise<boolean>,
  'getStatus' : (arg_0: [] | [Array<string>]) => Promise<Result>,
  'updateCycles' : (arg_0: Principal, arg_1: bigint) => Promise<boolean>,
}
export interface PublishError { 'code' : bigint, 'text' : string }
export type Result = { 'ok' : GetStatusResponse } |
  { 'err' : PublishError };
export type Value = Array<number>;
export type Witness = { 'labeled' : [Key, Witness] } |
  { 'fork' : [Witness, Witness] } |
  { 'leaf' : Value } |
  { 'empty' : null } |
  { 'pruned' : Hash };
export interface _SERVICE extends NIsp {}
