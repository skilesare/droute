export const idlFactory = ({ IDL }) => {
  const TrixValue = IDL.Rec();
  const Hash = IDL.Nat32;
  const ChunkRequest = IDL.Record({
    'sourceIdentifier' : IDL.Opt(Hash),
    'chunkID' : IDL.Nat,
    'event' : IDL.Opt(IDL.Text),
  });
  const Property = IDL.Record({
    'value' : TrixValue,
    'name' : IDL.Text,
    'immutable' : IDL.Bool,
  });
  TrixValue.fill(
    IDL.Variant({
      'Int' : IDL.Int,
      'Nat' : IDL.Nat,
      'Empty' : IDL.Null,
      'Nat16' : IDL.Nat16,
      'Nat32' : IDL.Nat32,
      'Nat64' : IDL.Nat64,
      'Blob' : IDL.Vec(IDL.Nat8),
      'Bool' : IDL.Bool,
      'Int8' : IDL.Int8,
      'Nat8' : IDL.Nat8,
      'Nats' : IDL.Variant({
        'thawed' : IDL.Vec(IDL.Nat),
        'frozen' : IDL.Vec(IDL.Nat),
      }),
      'Text' : IDL.Text,
      'Bytes' : IDL.Variant({
        'thawed' : IDL.Vec(IDL.Nat8),
        'frozen' : IDL.Vec(IDL.Nat8),
      }),
      'Int16' : IDL.Int16,
      'Int32' : IDL.Int32,
      'Int64' : IDL.Int64,
      'Option' : IDL.Opt(TrixValue),
      'Floats' : IDL.Variant({
        'thawed' : IDL.Vec(IDL.Float64),
        'frozen' : IDL.Vec(IDL.Float64),
      }),
      'Float' : IDL.Float64,
      'Principal' : IDL.Principal,
      'Array' : IDL.Variant({
        'thawed' : IDL.Vec(TrixValue),
        'frozen' : IDL.Vec(TrixValue),
      }),
      'Class' : IDL.Vec(Property),
    })
  );
  const AddressedChunk = IDL.Tuple(IDL.Nat, IDL.Nat, TrixValue);
  const ProcessError = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const ChunkResponse = IDL.Variant({
    'eof' : IDL.Vec(AddressedChunk),
    'err' : ProcessError,
    'chunk' : IDL.Vec(AddressedChunk),
    'parallel' : IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Vec(AddressedChunk)),
  });
  const Result = IDL.Variant({ 'ok' : ChunkResponse, 'err' : ProcessError });
  const Consumer = IDL.Service({
    'queryPipelinifyChunk' : IDL.Func([ChunkRequest], [Result], ['query']),
    'requestPipelinifyChunk' : IDL.Func([ChunkRequest], [Result], []),
    'testFullDataSendProcess' : IDL.Func(
        [IDL.Vec(AddressedChunk)],
        [IDL.Vec(AddressedChunk)],
        [],
      ),
    'testPullChunkProcess' : IDL.Func([], [IDL.Vec(AddressedChunk)], []),
    'testPullChunkUnknownProcess' : IDL.Func([], [IDL.Vec(AddressedChunk)], []),
    'testPullFullProcess' : IDL.Func([], [IDL.Vec(AddressedChunk)], []),
    'testPullFullQueryResponse' : IDL.Func([], [IDL.Vec(AddressedChunk)], []),
    'testPushFullResponse' : IDL.Func([], [IDL.Vec(AddressedChunk)], []),
  });
  return Consumer;
};
export const init = ({ IDL }) => { return []; };
