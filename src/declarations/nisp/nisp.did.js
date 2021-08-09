export const idlFactory = ({ IDL }) => {
  const Witness = IDL.Rec();
  const Key = IDL.Vec(IDL.Nat8);
  const Value = IDL.Vec(IDL.Nat8);
  const Hash = IDL.Vec(IDL.Nat8);
  Witness.fill(
    IDL.Variant({
      'labeled' : IDL.Tuple(Key, Witness),
      'fork' : IDL.Tuple(Witness, Witness),
      'leaf' : Value,
      'empty' : IDL.Null,
      'pruned' : Hash,
    })
  );
  const GetStatusResponse = IDL.Variant({
    'cycleBalance' : IDL.Tuple(IDL.Nat, Witness),
    'pointer' : IDL.Tuple(IDL.Principal, Witness),
    'notFound' : Witness,
  });
  const PublishError = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const Result = IDL.Variant({
    'ok' : GetStatusResponse,
    'err' : PublishError,
  });
  const NIsp = IDL.Service({
    'getStatus' : IDL.Func([], [Result], []),
    'updateCycles' : IDL.Func([IDL.Principal, IDL.Nat], [IDL.Bool], []),
  });
  return NIsp;
};
export const init = ({ IDL }) => { return []; };