import type { Principal } from '@dfinity/principal';
export interface _SERVICE {
  'test' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
}