export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const pipelinify_runner = IDL.Service({
    'Test' : IDL.Func([], [Result], []),
  });
  return pipelinify_runner;
};
export const init = ({ IDL }) => { return []; };