# Markdown-first architecture

`MarkdownNotes` owns the independent semantic tree, parser conversion boundary, portable vault, baseline/outbox/recovery, diagrams and merge decisions. `OneNoteGraph` implements delegated auth/transport and hierarchy/page/resource operations. `MarkdownEditor` owns native source editing, preview, selection, local rendering and sync states. The root Swift package and normal application launch integrate these targets. Research remains excluded from the product; legacy JSON/RTF source and data remain accessible through explicit legacy mode.

## Libraries and distribution

Evaluated against upstream sources on 26 October 2026:

- [Swift Markdown](https://github.com/swiftlang/swift-markdown) 0.9.0: Swift project's CommonMark/GFM AST, Apache 2.0 with Swift runtime exception; backed by cmark. Selected for semantic parsing.
- [SwiftSoup](https://github.com/scinfu/SwiftSoup) 2.14.3: maintained HTML DOM parser, MIT. Handles malformed HTML and resource/attribute extraction without a regex HTML parser.
- [MSAL Apple](https://github.com/AzureAD/microsoft-authentication-library-for-objc) 2.16.0: official delegated identity SDK. Uses O2N's private Keychain group, not Microsoft's first-party accounts. The app packages the dynamic framework and signs it before signing the app.
- [Mermaid](https://github.com/mermaid-js/mermaid) 11.17.2: current compatible 11.x line, MIT; npm tarball SHA-512 and bundled file SHA-256 verified. A nonpersistent hidden WebKit view runs strict mode with CSP denying network and WebKit HTTP/WebSocket block rules. No user content reaches an external renderer.

Third-party types stop at adapters. Package.resolved pins Swift dependencies; the Mermaid resource directory records its source, version, hash and license. Distribution includes dependency notices. Build/packaging orchestration remains Swift through the typed process boundary.

MSAL 2 uses the macOS data-protection Keychain. Native auth requires a valid Apple developer signature/profile with the app's private Keychain group; ad-hoc signing cannot grant that restricted capability. Runtime checks this executable's signature before any credential query. The local ad-hoc distribution remains usable for offline Markdown, with a clear native-auth gate. Developer packaging accepts `O2N_SIGNING_IDENTITY` and `O2N_PROVISIONING_PROFILE`, validates team/app/group/expiry, and never adds an invalid ad-hoc entitlement or downgrades credential storage. [Microsoft Keychain configuration](https://learn.microsoft.com/en-us/entra/msal/objc/howto-v2-keychain-objc)

## Graph contract and identity

Use delegated `/me`, `/users/{id}`, `/groups/{id}` or `/sites/{id}` roots. [App-only is unsupported](https://learn.microsoft.com/en-us/graph/api/resources/onenote-api-overview?view=graph-rest-1.0). Page identity includes a hash of the delegated account identity plus root/page ID; title and path are not identity. Follow pagination only within the selected HTTPS Graph collection. Reject redirects, bound retries, honor Retry-After, and never blindly retry writes. Do not log auth headers, tokens, account identifiers or note bodies.

[Supported PATCH operations](https://learn.microsoft.com/en-us/graph/onenote-update-page) use freshly fetched generated IDs. Outer absolute containers remain intact; only supported children are replaced/inserted. Unsupported remote objects and changes spanning ambiguous containers are protected. Binary resources use multipart Commands plus data parts. Fetch again immediately before write and verify semantic readback. Read/recheck/write retains a concurrency race: no conditional-write or ETag guarantee is claimed.

The setup command discovers the sanctioned CLI registration. When existing same-tenant authority permits, it backs up the public-client settings, appends only O2N's native callback, and verifies readback while preserving earlier callbacks. It never adds permission scopes, changes tenants/policies or extracts credentials. Local configuration contains only noncredential client metadata. Native MSAL sign-in is a separate gate; a CLI session never counts as native authentication proof.

## Diagram roundtrip

Fenced Mermaid remains the authored plain text. Sync renders a PNG locally and attaches the UTF-8 source with an `o2n-diagram-<source-hash>-<preview-hash>.mmd` filename. Official OneNote sees the image and source attachment. A new vault restores the fence only when downloaded source and preview hashes match the attachment metadata. A changed image or source marks the source stale, preserves the image and attachment separately, and retains earlier source in recovery history. Pixels never reconstruct source. Unsupported or failed rendering rejects push while keeping Markdown.

## Recovery and refresh

Portable `.md` and content-addressed `.assets` hold user content. Versioned per-page `.o2n` ledgers retain baseline, outbox, hashes, remote mappings and recovery state. Atomic file writes plus intent and previous-file hashes recover interrupted pulls without reverting newer remote content. Divergent external files/assets are never overwritten silently. Disjoint block changes merge; overlaps preserve local/remote/base and require explicit resolution, retaining history. Missing/inaccessible remote pages do not delete local notes. Renames/moves fail visibly until the ledger path is explicitly reconciled; no deletion inference.

The selected page refreshes every 120 seconds. Background refresh is read-only: remote-only changes pull; local edits wait for explicit sync. There is no undocumented delta/webhook assumption, background consent or background cloud write.

## Verification boundaries

The root local gate compiles/runs all targets and tests, builds release, exercises hidden native Markdown and legacy edit/undo/save/reopen, renders native previews and real offline Mermaid PNG, tests malformed diagrams, checks CLI rejection and evidence integrity, and checks whitespace. Package verification additionally checks nested signatures, copied framework/resources/licenses and the packaged binary's hidden tests.

Focused tests cover semantic conversion, assets, malformed/unsafe input, account isolation, pagination/retry, multipart bytes, offline reconnect, conflict/merge/recovery, diagram source recovery and stale-preview protection. Synthetic adapters are labelled as tests. Live Microsoft sign-in, synthetic cloud outcomes and native OneNote visual verification must be reported separately from local checks. No full integration-complete claim is valid until those required live gates pass.

## Live evidence (26 October 2026)

A real delegated CLI-managed probe created a new, clearly named synthetic notebook/section/page. The same `NoteSync` implementation passed formatted text/table same-page readback, independent remote edit refresh, offline outbox/reconnect, disjoint merge, and overlap preservation. The fixture IDs and conflicting copies remain local; no pre-existing notes were modified or fixtures deleted. The CLI kept token acquisition/cache inside its sanctioned process. This verifies Graph compatibility for those cases, not native MSAL, image/diagram upload or native OneNote rendering.

The existing registration's native callback is configured and re-read. Native MSAL acceptance is blocked by the absence of a valid Apple developer signing identity/profile on this machine: MSAL's private data-protection Keychain returned -34018 with ad-hoc signing; adding the restricted entitlement to an ad-hoc signature was rejected by macOS. The runtime now checks capability first, so the valid offline build does not repeatedly query credentials. No unsigned entitlement, credential downgrade, new permission scope or first-party token extraction is used. The full native synthetic acceptance command is implemented and awaits approved signing plus user Sign in.
