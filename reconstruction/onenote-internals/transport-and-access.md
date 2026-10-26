# Transport And Access Boundaries

This document records which OneNote endpoints were actually exercised, which native paths were established statically, and which account/backend capabilities remain unverified.

## Capability Matrix

| Surface | Consumer OneDrive | Work/school OneDrive | SharePoint/group | Evidence |
| --- | --- | --- | --- | --- |
| Graph delegated notebook/page API | Documented; untested here | Synthetic notebook/section/pages and resource readback exercised | Documented roots; untested here | Official contract plus scoped runtime |
| Graph app-only OneNote API | Unsupported by documented overview | Unsupported by documented overview | Unsupported by documented overview | Specification; no app-only attempt |
| CSI SOAP/cell transport | Consumer-specific listing/notification leads in binary; active host unknown | Cell transport implementation exists; account path unobserved | Cobalt versus CellStorageService selection implemented | Static only |
| Native realtime channel | Separate consumer gate found; not measured | RTC/notification handlers found; not measured | Backend-specific availability not measured | Static only |
| Mac `.bin` cache as an independent-client interface | No supported contract demonstrated | No supported contract demonstrated | No supported contract demonstrated | Untested; never mutated |

Graph's documented locations include `/me`, `/users/{id}`, `/groups/{id}`, and `/sites/{id}`. OneNote access requires delegated permissions; app-only support is explicitly absent. These service contracts do not grant our independent app Microsoft's first-party runtime privileges. [OneNote API overview](https://learn.microsoft.com/en-us/graph/api/resources/onenote-api-overview?view=graph-rest-1.0)

## Actual Requests In This Run

**Observed — sanctioned CLI:** `graph.microsoft.com`, API `v1.0`, using the existing Microsoft 365 CLI's managed session. No extracted Microsoft OneNote credentials, cloned client identity, bearer-token output, authentication headers, or account-store copies were used. A `/me` metadata check confirmed the expected principal case-insensitively; only the boolean result was retained.

| Method | Redacted path | Request representation | Result retained |
| --- | --- | --- | --- |
| POST | `/me/onenote/notebooks` | JSON, synthetic name | Returned notebook ID stored locally only |
| POST | `/me/onenote/notebooks/{test}/sections` | JSON, synthetic name | Returned section ID stored locally only |
| POST | `/me/onenote/sections/{test}/pages` | HTML or multipart/form-data | Two synthetic page IDs stored locally only |
| GET | `/me/onenote/pages/{test}/content?includeIDs=true` | No body, HTML requested | Sanitized synthetic projection and elapsed time |
| PATCH | `/me/onenote/pages/{test}/content` | JSON operations | CLI outcome plus verified readback |
| GET | `/{identity-root}/onenote/resources/{test}/$value` | Binary requested | Exact 47-byte synthetic payload comparison |
| GET | `/me/onenote/sections/{test}/pages` | Metadata-only select | Reconciled two pages, no unexpected titles |

**Measurement limits:** the CLI did not expose response status, HTTP version, response headers, or TLS negotiation in these probes. Request content types are known from supplied arguments; response body shapes were observed. A successful CLI result must not be relabeled as an observed `201`, `204`, HTTP/2 exchange, or native synchronization event. Elapsed times include CLI startup, token handling, network, service processing, and readback—not only transport latency. [Events](../../research/sync/runtime/graph-events.jsonl)

## Native Endpoint Construction

**Static — actual branch and references:** CSI `0x9c7a4` selects `/_vti_bin/Cobalt.ashx` when a capability flag combination and web URL are available; otherwise it uses `/_vti_bin/cellstorage.svc/CellStorageService`. A diagnostic explicitly describes falling back when a SharePoint/Cobalt server lacks a web URL. The path is joined to an input URL, user-agent/correlation metadata is prepared, an identity can be resolved for that URL, and asynchronous batch/worker objects are constructed. This is instruction-level endpoint-selection evidence, not an isolated string match. [Body](../../research/sync/static/lifecycle/TransportPathSelection.c), [literal references](../../research/sync/static/trace/transport-references.tsv)

**Static — SOAP listing:** `GetChangesSinceToken` reaches `CreateSoapWebService` and `_WsCall`. This establishes a compiled SOAP operation path; it does not supply a live hostname or demonstrate permission to invoke it under our app registration. [Call path](change-tracking.md)

**Specification:** FSSHTTP allows dependent cell-storage subrequests and lock/coauthoring operations. A protocol description is not an entitlement to a production backend. [Processing rules](https://learn.microsoft.com/en-us/openspecs/sharepoint_protocols/ms-fsshttp/918c3440-7d05-4c3a-8d51-0bad627bdb23)

## Native Wire Observation Limit

**Observed — OS metadata only:** one native process TCP connection terminated at remote port 443. Addresses were not exported. This establishes neither a hostname nor HTTP/TLS/websocket protocol details. No packet payload, TLS interception, process-memory inspection, security weakening, certificate installation, or debug attachment was attempted.

**Untested:** actual native hostnames, request methods/statuses/content types, transport version, notification negotiation, consumer/business differences, and independent-registration access to CSI endpoints. Safe next instrumentation must be limited to an owned synthetic client's requests; it cannot collect unrelated note/account traffic.
