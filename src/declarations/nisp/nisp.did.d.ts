import type { Principal } from '@dfinity/principal';
export interface GetWitnessRequest { 'principal' : Principal }
export type GetWitnessResponse = { 'noRecord' : null };
export interface NIsp {
  'getWitness' : (arg_0: GetWitnessRequest) => Promise<Result>,
}
export type Principal = Principal;
export interface PublishError { 'code' : bigint, 'text' : string }
export type Result = { 'ok' : GetWitnessResponse } |
  { 'err' : PublishError };
export interface _SERVICE extends NIsp {}