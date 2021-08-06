export const idlFactory = ({ IDL }) => {
  const Principal = IDL.Principal;
  const GetWitnessRequest = IDL.Record({ 'principal' : Principal });
  const GetWitnessResponse = IDL.Variant({ 'noRecord' : IDL.Null });
  const PublishError = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const Result = IDL.Variant({
    'ok' : GetWitnessResponse,
    'err' : PublishError,
  });
  const NIsp = IDL.Service({
    'getWitness' : IDL.Func([GetWitnessRequest], [Result], []),
  });
  return NIsp;
};
export const init = ({ IDL }) => { return []; };