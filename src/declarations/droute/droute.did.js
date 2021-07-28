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
  const EventPublishable = IDL.Record({
    'dataConfig' : DataConfig,
    'eventType' : IDL.Text,
  });
  const PublishStatus = IDL.Variant({
    'recieved' : IDL.Null,
    'delivered' : IDL.Null,
  });
  const PublishResponse = IDL.Record({
    'id' : IDL.Nat64,
    'status' : PublishStatus,
    'timeProcessed' : IDL.Int,
  });
  const PublishError = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const Result__1 = IDL.Variant({
    'ok' : PublishResponse,
    'err' : PublishError,
  });
  return IDL.Service({
    'getPublishingCanisters' : IDL.Func([IDL.Nat], [IDL.Vec(IDL.Text)], []),
    'publish' : IDL.Func([EventPublishable], [Result__1], []),
  });
};
export const init = ({ IDL }) => { return []; };