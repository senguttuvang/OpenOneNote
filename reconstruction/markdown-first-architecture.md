# Markdown-first architecture

`MarkdownNotes` owns the independent semantic tree, conversion boundary, portable vault, local baseline/outbox/recovery and merge decisions. `OneNoteGraph` implements delegated auth/transport and hierarchy/page/resource operations. `MarkdownEditor` owns native source editing, preview, selection and user-visible sync states. No new target depends on research or reads Microsoft's account/cache data. Legacy targets remain intact.

## Libraries

Evaluated 26 October 2026 against upstream sources:

- [Swift Markdown](https://github.com/swiftlang/swift-markdown): maintained Swift project parser, CommonMark/GFM AST backed by cmark; Apache 2.0 with Swift runtime exception. Selected for semantic parsing, not Markdown-to-HTML regex substitution. Version 0.9.0.
- [SwiftSoup](https://github.com/scinfu/SwiftSoup): maintained Swift HTML DOM parser, MIT; selected for malformed HTML recovery, attribute/resource extraction and normalization. Version 2.14.3.
- [MSAL Apple](https://github.com/AzureAD/microsoft-authentication-library-for-objc): Microsoft's supported delegated identity SDK with client-managed Keychain cache. Application registration/redirect/Notes consent must be supplied through sanctioned configuration; never substitute first-party tokens.

Third-party types remain inside adapters. Dependency licenses must accompany distribution. Package.resolved pins transitive revisions. Replacing either parser does not change portable note files or the domain remote port.

## Graph contract

Use delegated `/me`, `/users/{id}`, `/groups/{id}` or `/sites/{id}` roots. [App-only is unsupported](https://learn.microsoft.com/en-us/graph/api/resources/onenote-api-overview?view=graph-rest-1.0). Follow pagination only on HTTPS graph.microsoft.com/v1.0, reject redirects, bound retries and honor Retry-After. Never log HTTP response bodies or auth headers. No write retry after an ambiguous result.

[Supported PATCH operations](https://learn.microsoft.com/en-us/graph/onenote-update-page) operate on current generated IDs. Absolute outer containers cannot be replaced. Replace supported child ranges, preserving unsupported objects and page identity; re-fetch and read back. [Binary resources](https://learn.microsoft.com/en-us/graph/onenote-images-files) use multipart Commands plus binary parts. Graph normalizes HTML; compare semantics and retain unchanged local punctuation. No validated conditional-write support is assumed: read/recheck/write has a residual race, which is exposed rather than advertised as atomic sync.

## Recovery

Each page has a stable UUID filename and ledger identity root/page ID. `.md` is authored content; JSON only records sync/recovery metadata and baseline. Assets are content addressed and sandboxed against traversal and symlinks. Atomic single-file writes plus ledger intent preserve interrupted materialization/outbox state. A divergent external file is never overwritten during network operations. Conflicts retain local source, baseline and remote recovery copy. Remote deletion/access failures retain all local content. No automatic file deletion or filename identity inference.

## Current delivery evidence and gates

The new modules compile together in an isolated Swift package with the three exact dependency versions above. The package runs focused conversion/vault/Graph/sync regression tests and a hidden native Markdown edit/undo/reopen/render probe. The existing repository `swift run openonenote-dev check` also passes, but its manifest does **not yet include these new targets**. This distinction is intentional and must not be represented as integrated app delivery.

Shared-file ownership is pending: the handoff requires coordination before changing Package.swift, app composition, packaging and local gate wiring. Requests to the idle Native Fidelity session are queued, not acknowledged. A user ownership question is pending. Until ownership is granted, the default app remains the legacy editor and this branch is an implementation checkpoint, not a ready-to-merge product PR.

Live O2N delegated sign-in and a synthetic same-page cloud roundtrip have not run. The human gate is a sanctioned public-client registration with its registered native redirect and Notes.ReadWrite consent, followed by explicit Sign in. Do not reuse extracted OneNote credentials or claim the existing CLI's session proves O2N MSAL sign-in. Personal and SharePoint root handling are implemented but not live-verified. No existing notes or synthetic cloud pages have been written by this implementation session.

Bounded background refresh is implemented for the selected page every 120 seconds, with no background cloud writes or consent prompts. It pulls remote-only changes and leaves local outbox edits for explicit sync. Native application lifecycle starts/stops the loop; hidden verification never starts it. Automated coverage verifies read-only refresh behavior, not a live Microsoft polling session.

Pending product capabilities: rendered Mermaid PNG/source attachment recovery and stale-diagram detection, richer local hierarchy navigation, and distribution validation with the dynamic MSAL framework and bundled dependency licenses. Common supported content has independent regression coverage; unsupported structures and ambiguous container mappings reject destructive pushes. These gaps prevent a full milestone-complete claim.
