export const idlFactory = ({ IDL }) => {
  const test_runner_droute_utilities = IDL.Service({
    'test' : IDL.Func(
        [],
        [IDL.Variant({ 'fail' : IDL.Text, 'success' : IDL.Null })],
        [],
      ),
  });
  return test_runner_droute_utilities;
};
export const init = ({ IDL }) => { return []; };