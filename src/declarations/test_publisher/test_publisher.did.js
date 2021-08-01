export const idlFactory = ({ IDL }) => {
  const Witness = IDL.Rec();
  const Hash__1 = IDL.Nat32;
  const AddressedChunk = IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Vec(IDL.Nat8));
  const ChunkRequest = IDL.Record({
    'sourceIdentifier' : IDL.Opt(Hash__1),
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
      'sourceIdentifier' : IDL.Opt(Hash__1),
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
  const Principal = IDL.Principal;
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
  const MerkleTreeWitness = IDL.Variant({
    'labeled' : IDL.Tuple(Key, Witness),
    'fork' : IDL.Tuple(Witness, Witness),
    'leaf' : Value,
    'empty' : IDL.Null,
    'pruned' : Hash,
  });
  const test_publisher = IDL.Service({
    '__dRouteNotify' : IDL.Func([DRouteEvent], [NotifyResponse], []),
    '__dRouteSubValidate' : IDL.Func(
        [Principal, IDL.Nat],
        [IDL.Bool, IDL.Vec(IDL.Nat8), MerkleTreeWitness],
        [],
      ),
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
  return test_publisher;
};
export const init = ({ IDL }) => { return []; };