export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'test' : IDL.Func(
        [],
        [IDL.Variant({ 'fail' : IDL.Text, 'success' : IDL.Null })],
        [],
      ),
    'testSimpleNotify' : IDL.Func(
        [],
        [IDL.Variant({ 'fail' : IDL.Text, 'success' : IDL.Null })],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };