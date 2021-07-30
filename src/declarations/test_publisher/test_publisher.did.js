export const idlFactory = ({ IDL }) => {
  const Hash = IDL.Nat32;
  const AddressedChunk = IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Vec(IDL.Nat8));
  const ChunkRequest = IDL.Record({
    'sourceIdentifier' : IDL.Opt(Hash),
    'chunkID' : IDL.Nat,
    'event' : IDL.Opt(IDL.Text),
  });
  const ProcessError = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const ChunkResponse = IDL.Variant({
    'eof' : IDL.Vec(AddressedChunk),
    'err' : ProcessError,
    'chunk' : IDL.Vec(AddressedChunk),
    'parallel' : IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Vec(AddressedChunk)),
  });
  const Result = IDL.Variant({ 'ok' : ChunkResponse, 'err' : ProcessError });
  const DataSource = IDL.Service({
    'queryPipelinifyChunk' : IDL.Func([ChunkRequest], [Result], ['query']),
    'requestPipelinifyChunk' : IDL.Func([ChunkRequest], [Result], []),
  });
  const DataConfig = IDL.Variant({
    'internal' : IDL.Null,
    'pull' : IDL.Record({
      'sourceIdentifier' : IDL.Opt(Hash),
      'data' : IDL.Opt(IDL.Vec(AddressedChunk)),
      'mode' : IDL.Variant({ 'pullQuery' : IDL.Null, 'pull' : IDL.Null }),
      'sourceActor' : IDL.Opt(DataSource),
      'totalChunks' : IDL.Opt(IDL.Nat32),
    }),
    'push' : IDL.Null,
    'dataIncluded' : IDL.Record({ 'data' : IDL.Vec(AddressedChunk) }),
  });
  const DRouteEvent = IDL.Record({
    'source' : IDL.Principal,
    'userID' : IDL.Nat,
    'dataConfig' : DataConfig,
    'dRouteID' : IDL.Nat,
    'eventType' : IDL.Text,
  });
  const PublishError = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const NotifyResponse = IDL.Variant({ 'ok' : IDL.Bool, 'err' : PublishError });
  const Result__1 = IDL.Variant({
    'ok' : NotifyResponse,
    'err' : PublishError,
  });
  return IDL.Service({
    '__dRouteNotify' : IDL.Func([DRouteEvent], [Result__1], []),
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
    'testSubscribe' : IDL.Func(
        [],
        [IDL.Variant({ 'fail' : IDL.Text, 'success' : IDL.Null })],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };