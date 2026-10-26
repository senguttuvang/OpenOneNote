# Change Tracking And Remote Invalidation

This document reconstructs bounded native scheduling/notification paths from analyzed CSI functions and separates those paths from the Graph behavior measured in synthetic pages.

## Static Subsystem Boundaries

- **Revision/knowledge layer:** `CreateRevisionManifestScaffold` (`0x1dc060`) copies revision identifiers/serial state; `CreateKnowledge` (`0x26afb8`) delegates allocation, and `FGetCellKnowledge` (`0x542cbc`) queries a cell-specific view. [Scaffold](../../research/sync/static/CreateRevisionManifestScaffold.c), [knowledge query](../../research/sync/static/FGetCellKnowledge.c)
- **Cell storage adapter:** `CreateCellStorageOverHttp` (`0x23cf98`) allocates and initializes a cell store, conditionally binds a provided request/user manager, and optionally wraps it with `GetCellStorageMultiRoundTrip`. The simple overload at `0x7369b0` shares allocation/initialization. The helper at `0x736a88` locks a recursive mutex and changes a flag; an earlier working label implying request binding was corrected. [Full constructor](../../research/sync/static/CreateCellStorageOverHttp_full.c), [flag helper](../../research/sync/static/follow/CellStorageFlagMutation.c)
- **Content scheduler:** the function at `0x108e14`, reached through a reference to the `ContentSyncScheduler::SubmitJob` diagnostic literal, obtains job-related interfaces, registers several callbacks, inserts work into scheduler state, checks a required scheduler interface, and forwards the operation. This establishes a job/callback boundary; it does not recover the exact meaning of every virtual slot. [Body](../../research/sync/static/lifecycle/LiteralRef_ba22c2_00108e14.c)
- **Transport batch/executor:** `0x9c7a4` constructs a relative service path, builds request metadata, obtains a request factory/worker, creates futures, and uses `Mso::Async::ConcurrentQueue`/`DispatchQueueExecutor`. The exported factory/worker/batch functions are mostly wrappers, so their implementations were followed rather than treated as the whole pipeline. [Analyzed transport builder](../../research/sync/static/lifecycle/TransportPathSelection.c)

## Binary Serialization

**Static:** `SerializeDataElementPackage` at `0x51c60c` has an interface-provided serialization path and a fallback that writes a size-dependent two-byte, four-byte, or extended header; enumerates elements; calls `0x281f20`; and writes a one-byte `0x55` terminator. The element serializer at `0x281f20` branches on element kind, writes identifier/serial-related fields through subordinate serializers, and ends its fallback with `0x05`. Virtual calls and inferred types remain unresolved in places. [Package serializer](../../research/sync/static/SerializeDataElementPackage.c), [element serializer](../../research/sync/static/follow/SerializeDataElement.c)

**Inference:** the compiled incremental cell/revision machinery uses structured binary streams. This does not mean every request from this OneNote process uses this format, nor does the serializer alone establish a complete wire schema or active endpoint.

## Hierarchy Changes Are Separate From Content Changes

**Static:** `GetChangesSinceToken` (`0x79ff78`) calls a channel-creation helper (`0x79e734`), which invokes `Mso::WebServices::CreateSoapWebService`. Its call helper (`0x79dc78`) invokes `_WsCall` with a compiled descriptor. The result handling reads `href`, `displayname`, folder/hidden flags, resource IDs, sizes, dates, and per-item status, and returns a change-token output plus item descriptors. SOAP faults and error-string paths are present. [Entry/body](../../research/sync/static/GetChangesSinceToken.c), [SOAP channel](../../research/sync/static/follow/ChangeTokenChannelCreation.c), [call](../../research/sync/static/follow/ChangeTokenServiceCall.c)

**Inference:** this function concerns listing/hierarchy discovery and must not be presented as a Graph page-content `/delta` endpoint or a recovered character-level merge algorithm.

## Host Notifications And Timers

- **Static — update handler:** `0x6b4e58` references `HostNotifications::ReceivedHostUpdateNotification`, queries subscription state keyed by file/update type, and conditionally forwards an update to downstream handlers. It also records subscription/heartbeat timing and evaluates `EnableSignalRCore` and `DeprecateCppRestSdk` feature gates. [Body](../../research/sync/static/lifecycle/LiteralRef_bb95f6_006b4e58.c)
- **Static — completion/state:** `0x3a2b04` references `HostNotifications::OnRequestCompletion`, records detected-update and RTC state, and conditionally invokes completion-interface methods. `0x3a3ee8` queries RTC status, with an explicit failure path when the connection or connection manager is unavailable. [Completion](../../research/sync/static/lifecycle/LiteralRef_bb97cd_003a2b04.c), [RTC status](../../research/sync/static/lifecycle/LiteralRef_bb9732_003a3ee8.c)
- **Static — grace period:** `0x6b28f0` compares an update-related count against helper-provided thresholds, logs entry into a grace period at one boundary, and chooses a later transition based on an interface state. The exact count/enum semantics remain inferred. [Body](../../research/sync/static/lifecycle/LiteralRef_bb90de_006b28f0.c)
- **Static — configurable timing:** `0x1c389c` reads `ListenToHostNotifications` (`0xfcd`), `HostNotificationsHeartbeatIntervalInSeconds` (`0xfce`), and `HostNotificationsVerifyPingIntervalPct` (`0xfcf`) through `Storage::Configuration`. Another analyzed path records a separate consumer notification setting. These are configuration reads, not observed values or proof the gate is enabled. [Configuration/telemetry body](../../research/sync/static/lifecycle/LiteralRef_b98ddb_001c389c.c)

**Inference:** this build includes both event-oriented remote invalidation and timer/health machinery. It is unwarranted to describe it as only periodic polling, or to claim that a websocket delivered this experiment's update. A live notification may be an invalidation requiring a subsequent fetch, rather than the complete page payload.

## What Was Not Measured

**Untested:** keystroke debounce interval; dirty-queue persistence/order; foreground versus background scheduling; polling frequency; heartbeat interval actually selected for this account; websocket/SignalR connection activation; native remote-edit receipt; retry backoff; conflict UI. No local filesystem watcher import was attributed to notebook external-change detection. `FSEventStream*` imports in the main binary remain only imports until a relevant call path is established.

**Observed — Graph only:** the remote append and stale-ID tests exercised service mutations/readback. The newly created notebook was not deliberately opened in the native app, and its title was absent from five bounded `ServerListings` files. That negative scan cannot exclude encoded/listing changes or prove the notebook was invisible in native UI.
