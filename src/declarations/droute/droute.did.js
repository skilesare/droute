export const idlFactory = ({ IDL }) => {
  const ValidSourceOptions = IDL.Variant({
    'blacklist' : IDL.Vec(IDL.Principal),
    'whitelist' : IDL.Vec(IDL.Principal),
    'dynamic' : IDL.Record({ 'canister' : IDL.Text }),
  });
  const EventRegistrationStable = IDL.Record({
    'publishingCanisters' : IDL.Vec(IDL.Text),
    'validSources' : ValidSourceOptions,
    'eventType' : IDL.Text,
  });
  const AddressedChunkArray = IDL.Vec(
    IDL.Tuple(IDL.Nat, IDL.Nat, IDL.Vec(IDL.Nat8))
  );
  const Entry = IDL.Record({
    'data' : AddressedChunkArray,
    'primaryID' : IDL.Nat,
    'marker' : IDL.Nat,
  });
  const ReadResponse = IDL.Record({
    'data' : IDL.Vec(Entry),
    'lastID' : IDL.Opt(IDL.Nat),
    'lastMarker' : IDL.Opt(IDL.Nat),
  });
  const ProcessQueueResponse = IDL.Record({
    'queueLength' : IDL.Nat,
    'eventsProcessed' : IDL.Nat,
  });
  const PublishError = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const Result_2 = IDL.Variant({
    'ok' : ProcessQueueResponse,
    'err' : PublishError,
  });
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
    'dataIncluded' : IDL.Record({ 'data' : IDL.Vec(AddressedChunk) }),
  });
  const EventPublishable = IDL.Record({
    'userID' : IDL.Nat,
    'dataConfig' : DataConfig,
    'eventType' : IDL.Text,
  });
  const PublishStatus = IDL.Variant({
    'recieved' : IDL.Null,
    'delivered' : IDL.Null,
  });
  const Principal = IDL.Principal;
  const PublishResponse = IDL.Record({
    'status' : PublishStatus,
    'dRouteID' : IDL.Nat,
    'timeRecieved' : IDL.Int,
    'publishCanister' : Principal,
  });
  const PublishError__1 = IDL.Record({ 'code' : IDL.Nat, 'text' : IDL.Text });
  const Result_1 = IDL.Variant({
    'ok' : PublishResponse,
    'err' : PublishError__1,
  });
  const SubscriptionFilter = IDL.Variant({ 'notImplemented' : IDL.Null });
  const SubscriptionThrottle = IDL.Variant({ 'notImplemented' : IDL.Null });
  const SubscriptionRequest = IDL.Record({
    'userID' : IDL.Nat,
    'filter' : IDL.Opt(SubscriptionFilter),
    'throttle' : IDL.Opt(SubscriptionThrottle),
    'destinationSet' : IDL.Vec(IDL.Principal),
    'eventType' : IDL.Text,
  });
  const SubscriptionResponse = IDL.Record({
    'userID' : IDL.Nat,
    'subscriptionID' : IDL.Nat,
  });
  const Result = IDL.Variant({
    'ok' : SubscriptionResponse,
    'err' : PublishError,
  });
  const DRoute = IDL.Service({
    'getEventRegistration' : IDL.Func(
        [IDL.Text],
        [IDL.Opt(EventRegistrationStable)],
        [],
      ),
    'getProcessingLogs' : IDL.Func([IDL.Text], [ReadResponse], []),
    'getProcessingLogsByIndex' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [ReadResponse],
        [],
      ),
    'getPublishingCanisters' : IDL.Func([IDL.Nat], [IDL.Vec(IDL.Text)], []),
    'processQueue' : IDL.Func([], [Result_2], []),
    'publish' : IDL.Func([EventPublishable], [Result_1], []),
    'subscribe' : IDL.Func([SubscriptionRequest], [Result], []),
  });
  return DRoute;
};
export const init = ({ IDL }) => { return []; };