# Revisions, Offline State, And Recovery

This document distinguishes published revision-store behavior, analyzed CSI mechanisms, and the recovery/offline behaviors that remain untested on the running Mac client.

## Revision Layers

- **Specification — ONESTORE revisions:** revisions organize changes within object spaces; they are part of the persistence representation. They are not synonymous with an application's visible page-history UI. [ONESTORE revisions](https://learn.microsoft.com/en-us/openspecs/office_file_formats/ms-onestore/344c9aa5-2826-4b61-b1bb-1ef841b1b79e)
- **Specification — synchronization graph:** a storage index resolves cell and revision manifests. A cell selects a current revision; revision manifests refer to object groups and a base revision. Unchanged object data can be inherited through earlier revisions. Large user data can be held in separate blobs. [FSSHTTPB model](https://learn.microsoft.com/en-us/openspecs/sharepoint_protocols/ms-fsshttpb/6c7e4447-6ccd-4764-8dbc-17a382fb631d)
- **Static — scaffold creation:** CSI `0x1dc060` allocates an object, copies two extended identifiers plus a serial-number structure, and publishes the output through a helper. This is an implemented constructor path, not merely a named import. [Pseudocode](../../research/sync/static/CreateRevisionManifestScaffold.c)
- **Static — knowledge extraction:** `0x542cbc` queries a knowledge interface and returns whether the cell-knowledge interface was available. It does not establish the contents or persistence lifetime of an account's current knowledge. [Pseudocode](../../research/sync/static/FGetCellKnowledge.c)

## Transactions And Local Recovery

**Specification:** ONESTORE includes a transaction log to protect integrity across asynchronous writes. The published header contains transaction-log and file-node-list references plus an expected file length. These are file-format contracts, not proof that the running Mac `.bin` allocator uses the identical on-disk header/layout. [Applicability](https://learn.microsoft.com/en-us/openspecs/office_file_formats/ms-onestore/83daaabe-53ba-4e6e-a56d-cc5cd41bbb1f), [header fields](https://learn.microsoft.com/en-us/openspecs/office_file_formats/ms-onestore/2b394c6b-8788-441f-b631-da1583d772fd)

**Observed:** the native process held cache descriptors while a separate backup tree contained `.one` files. The persisted search schema tracks pending versus indexed revisions and reset state. No crash, forced termination, or damaged-cache experiment was performed.

**Inference:** notebook edits, cache persistence, derived-index catch-up, network acknowledgement, and backup generation can advance at different times. A successful save or a search hit is insufficient evidence that the server accepted the latest edit.

## Offline And Reconnect

**Specification/product guidance:** OneNote Mac automatically synchronizes its cloud notebooks; Microsoft's current recovery matrix documents automatic/manual Mac backups, weekly backup frequency, and two recent copies. Those published defaults do not establish this user's current settings or the completeness of the observed backup tree. [Sync guidance](https://support.microsoft.com/en-us/onenote/onenote-help-and-learning/sync-a-notebook-in-onenote), [recovery matrix](https://support.microsoft.com/en-us/onenote/onenote-platform-data-protection-recovery)

**Untested:** locally create/edit a native synthetic page while its network transport is isolated, reconnect it, and validate both local and remote content after acknowledgement. There was no supported isolation mechanism already demonstrated that would leave other OneNote notebooks and the user's network untouched. No global disconnect, account signout, app quit, preference change, or cache mutation was used as a substitute.

## Coherency And Conflict

**Specification:** FSSHTTP describes a coherency failure followed by download, merge, and another upload; an unmergeable result must be surfaced to the user. [Protocol overview](https://learn.microsoft.com/en-us/openspecs/sharepoint_protocols/ms-fsshttp/6d078cbe-2651-43a0-b460-685ac3f14c45) FSSHTTPB separately identifies coherency failure, missing revision, bad token, and busy/retry errors. [Cell errors](https://learn.microsoft.com/en-us/openspecs/sharepoint_protocols/ms-fsshttpb/81a517ea-ca3e-4483-9fa2-3ae6834abcf0)

**Observed — narrower Graph experiment:** two sequential reads returned the same generated paragraph ID. Writer A replaced that paragraph successfully. Writer B's request using the old ID failed; final readback contained A and excluded B. The CLI emitted neither HTTP status nor a diagnostic body. It could be target invalidation or another failure; this does not demonstrate native revision coherency, a server CAS guarantee, or a simultaneous-edit merge. [Experiment events](../../research/sync/runtime/graph-events.jsonl), [final projection](../../research/sync/runtime/stale-final.sanitized.html)

**Proposed contract:** keep a durable local edit journal/outbox and server-acknowledged base separate. Retain both versions when merge cannot be proven safe. Require recovery/retry tests before valuable notebooks depend on two-way sync. See [Swift contracts](swift-contracts.md).
