# OneNote Storage And Synchronization

This internal investigation explains OneNote Mac storage, revision structures, synchronization paths, and the limits of an independent Swift client, using build-pinned static analysis and controlled runtime experiments on 26 October 2026.

## Findings

- **Mixed binary document model:** published OneNote objects contain text, formatting, geometry, object references, and separate file data. Graph HTML is a projection of that model.
- **Three different local stores observed:** opaque `.bin` files in the active cache, `.one` files in `Backup`, and SQLite indexes containing revision/identity/text-related schema. A search index is not the notebook's durable source.
- **Native incremental machinery exists:** analyzed CSI bodies construct HTTP cell storage, serialize binary data elements, select Cobalt or CellStorageService paths, call a SOAP change-token operation, dispatch asynchronous work, and process host-notification state. This is stronger evidence than framework presence; it still does not establish which path this account used live.
- **Measured Graph behavior:** two positioned containers survived create/readback; text/list/table semantics survived normalization; a 47-byte attachment downloaded exactly; appending worked; replacing outer-container content preserved the old width; a stale generated-ID replacement failed after a successful first writer.
- **Native synchronization remains partially unresolved:** no native edit, controlled native remote-edit receipt, offline/reconnect, crash/recovery, or decrypted native wire experiment was performed. No claim of full two-way interoperability or measured push latency follows from this investigation.

## Topic Guide

| Question | Document |
| --- | --- |
| Binary, plain text, canvas, attachments, published versus private | [Document model](document-model.md) |
| Actual Mac paths and file formats | [Local storage](local-storage.md) |
| Offline revisions, transactions, recovery | [Revisions and recovery](revisions-and-recovery.md) |
| Dirty work, scheduling, remote changes, notifications | [Change tracking](change-tracking.md) |
| Endpoint, transport, and authentication capabilities | [Transport and access](transport-and-access.md) |
| Local-edit and remote-edit flows | [Sequences](sequences.md) |
| Independent implementation contracts | [Swift compatibility contracts](swift-contracts.md) |
| User-supplied parsers and MCP examples | [Prior art comparison](prior-art.md) |
| Experiment results, provenance, limitations | [Evidence catalogue](../../research/sync/README.md) |

## Claim Labels

- **Observed:** measured on this Mac or through this run's synthetic Graph objects; scope stated beside the claim.
- **Static:** an instruction/decompiler/reference relationship in the pinned binary, or explicitly identified metadata/literal evidence.
- **Specification:** Microsoft's published contract, with a source link; not a runtime observation.
- **Inference:** interpretation supported by evidence but not directly established.
- **Untested:** the required experiment has not run or its prerequisite was unavailable.

The runtime exception was authorized explicitly for this investigation. The existing `Sources/OneNoteResearch` static-only boundary remains intact; no application targets, existing notes, private caches, or credentials became dependencies or committed fixtures.
