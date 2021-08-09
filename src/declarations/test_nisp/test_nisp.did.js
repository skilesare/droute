export const idlFactory = ({ IDL }) => {
  const test_publisher = IDL.Service({
    'test' : IDL.Func(
        [],
        [IDL.Variant({ 'fail' : IDL.Text, 'success' : IDL.Null })],
        [],
      ),
    'testGetWitnessEmpty' : IDL.Func(
        [],
        [IDL.Variant({ 'fail' : IDL.Text, 'success' : IDL.Null })],
        [],
      ),
    'testGetWitnessSubscribed' : IDL.Func(
        [],
        [IDL.Variant({ 'fail' : IDL.Text, 'success' : IDL.Null })],
        [],
      ),
  });
  return test_publisher;
};
export const init = ({ IDL }) => { return []; };