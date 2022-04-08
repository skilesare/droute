export const idlFactory = ({ IDL }) => {
  const TrixValue = IDL.Rec();
  const ExecutionConfig = IDL.Record({
    'executionMode' : IDL.Variant({ 'manual' : IDL.Null, 'onLoad' : IDL.Null }),
  });
  const ResponseConfig = IDL.Record({
    'responseMode' : IDL.Variant({
      'pull' : IDL.Null,
      'push' : IDL.Null,
      'local' : IDL.Nat,
    }),
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
  const Hash = IDL.Nat32;
  const AddressedChunk = IDL.Tuple(IDL.Nat, IDL.Nat, TrixValue);
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
  const Result__1 = IDL.Variant({ 'ok' : ChunkResponse, 'err' : ProcessError });
  const DataSource = IDL.Service({
    'queryPipelinifyChunk' : IDL.Func([ChunkRequest], [Result__1], ['query']),
    'requestPipelinifyChunk' : IDL.Func([ChunkRequest], [Result__1], []),
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
    'local' : IDL.Nat,
    'dataIncluded' : IDL.Record({ 'data' : IDL.Vec(AddressedChunk) }),
  });
  const ProcessRequest = IDL.Record({
    'executionConfig' : ExecutionConfig,
    'responseConfig' : ResponseConfig,
    'event' : IDL.Opt(IDL.Text),
    'processConfig' : IDL.Opt(TrixValue),
    'dataConfig' : DataConfig,
  });
  const ProcessType = IDL.Variant({
    'error' : IDL.Null,
    'parallel' : IDL.Record({
      'stepMap' : IDL.Vec(IDL.Bool),
      'steps' : IDL.Nat,
    }),
    'sequential' : IDL.Nat,
    'unconfigured' : IDL.Null,
  });
  const PipeInstanceID = IDL.Nat32;
  const ProcessResponse = IDL.Variant({
    'stepProcess' : IDL.Record({
      'status' : ProcessType,
      'pipeInstanceID' : PipeInstanceID,
    }),
    'intakeNeeded' : IDL.Record({
      'chunkMap' : IDL.Vec(IDL.Bool),
      'totalChunks' : IDL.Nat,
      'currentChunks' : IDL.Nat,
      'pipeInstanceID' : PipeInstanceID,
    }),
    'local' : IDL.Nat,
    'outtakeNeeded' : IDL.Record({ 'pipeInstanceID' : PipeInstanceID }),
    'dataIncluded' : IDL.Record({ 'payload' : IDL.Vec(AddressedChunk) }),
  });
  const Result = IDL.Variant({ 'ok' : ProcessResponse, 'err' : ProcessError });
  const ChunkPush = IDL.Record({
    'chunk' : ChunkResponse,
    'pipeInstanceID' : PipeInstanceID,
  });
  const Processor = IDL.Service({
    'process' : IDL.Func([ProcessRequest], [Result], []),
    'pushChunk' : IDL.Func([ChunkPush], [Result], []),
  });
  return Processor;
};
export const init = ({ IDL }) => { return []; };
