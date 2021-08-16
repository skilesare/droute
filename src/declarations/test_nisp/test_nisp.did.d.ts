import type { Principal } from '@dfinity/principal';
export interface test_publisher {
  'test' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
  'testGetMenu' : () => Promise<{ 'fail' : string } | { 'success' : null }>,
  'testGetWitnessEmpty' : () => Promise<
      { 'fail' : string } |
        { 'success' : null }
    >,
  'testGetWitnessSubscribed' : () => Promise<
      { 'fail' : string } |
        { 'success' : null }
    >,
}
export interface _SERVICE extends test_publisher {}