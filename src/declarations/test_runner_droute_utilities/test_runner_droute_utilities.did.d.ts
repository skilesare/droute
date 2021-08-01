import type { Principal } from '@dfinity/principal';
export interface test_runner_droute_utilities {
  'test' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
}
export interface _SERVICE extends test_runner_droute_utilities {}