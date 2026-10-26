# Independent Swift Compatibility Contracts

This proposal translates observed OneNote storage and Graph constraints into explicit requirements for a future independent Swift implementation; this research PR does not implement cloud sync or binary import.

## Domain And Storage

- **Owned model:** keep notebook/page/container/block/asset identities independent from Microsoft IDs. External mappings belong to a compatibility adapter.
- **Rich text:** preserve semantic runs, lists, tables, links, geometry, media, and original unsupported bytes where available. `NSAttributedString`/RTF and Graph HTML each serve adapters; neither is the entire interchange model.
- **Revision separation:** distinguish local edit sequence, server base/knowledge, visible version history, undo, and backup checkpoints.
- **Local transaction:** commit content/assets and an outbox operation consistently before claiming durable local success. An actor serializes local access but does not itself prevent a stale external writer.
- **Derived indexes:** index revision progress separately; rebuilding search cannot overwrite authoritative content. The native schema's `IndexedRID`/`PendingIndexRID` supports this separation as an observation, not as a format to copy.

## Graph Adapter

- **Legitimate authentication:** own registered client, explicit delegated scope, supported refresh-capable cache. Do not inherit Microsoft's native identity or a reference tool's public Graph Explorer default/plaintext token file.
- **Explicit capability results:** classify operations as preserved, normalized, rejected, ignored, or untested. The measured accepted-content/ignored-width replacement requires separate content and geometry results.
- **Fresh element mapping:** read current generated IDs before mutation. A stale-ID failure must retain local edits and trigger re-read/reconciliation; it must not cause blind full-page replacement.
- **Retry safety:** after a timeout or ambiguous create, reconcile the owned object's identity before retrying. Preserve operation identity and avoid duplicate pages/attachments. Honor throttling when exposed by the supported client.
- **Attachment integrity:** compare exact bytes/content hashes and media metadata. The observed 47-byte fixture is a small success case, not proof for arbitrary large/binary/ink objects.
- **Scope guard:** writes only to explicitly owned/selected objects; lossless readback expectations are per feature. Never replace an existing valuable page merely to emulate a resize.

## Native Protocol Adapter

- **Separate feasibility gate:** published FSSHTTP/B schemas and compiled CSI paths do not prove backend access under a legitimate independent registration.
- **No proprietary runtime dependency:** Microsoft frameworks, cache allocators, decompiled bodies, and original research assets remain research-only. Implement from documented contracts and independent tests.
- **Knowledge and conflicts:** keep opaque server knowledge/base state; test coherency, lost acknowledgements, missing revisions, partial replies, token expiry, and overlapping edits. Unknown outcomes preserve both local and remote versions.
- **Remote invalidation:** treat push as a hint until payload semantics and revision identity are known. A recovery fetch/reconciliation path remains necessary; timers require measured policy rather than copied binary constants.
- **Cache import:** do not open/mutate Microsoft's live `.bin` cache as the app's persistence adapter. A future read-only importer needs validated object boundaries, revision membership, corruption limits, and synthetic fixtures.

## Acceptance Evidence Still Required

| Capability | Minimum meaningful evidence |
| --- | --- |
| Binary `.one` import | Synthetic revision/object graphs, unknown-property retention, malformed references, exact attachment bytes; differential parser results |
| Native alternating edits | Same synthetic page identity, local edit → server readback → separate-client edit → native receipt |
| Offline/reconnect | Scoped transport isolation, durable edits, restart/reconnect, no duplicate/lost operations |
| Conflict handling | Same-block and disjoint edits from stale bases, explicit conflict preservation, repeatable recovery |
| Canvas fidelity | Native-rendered text/list/table/position/media/ink comparisons, not HTML alone |
| Production storage | Transaction interruption/migration/recovery tests and multiple-writer rejection |

Use the [supplied parser prior art](prior-art.md) for file-level comparison. Its reviewed scope does not replace the native/backend experiments above. Follow-up execution remains in Beads rather than a second task list in these documents.
