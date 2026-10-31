# O2N Product Roadmap

O2N aims to extend a familiar native Mac notebook workflow with portable Markdown and supported OneNote interoperability. This roadmap separates the implemented developer-preview baseline from planned and exploratory work; it is direction, not a delivery-date commitment.

## Implemented Baseline

- **Native writing:** notebook/section/page navigation, ordinary rich editing by default, immediate local page/section creation with inline names, supported formatting, undo and local persistence.
- **Markdown capability:** a Home ribbon icon exposes source, split and reading views inside the same page. Markdown files and companion assets remain portable.
- **Offline diagrams:** Mermaid renders locally. The supported cloud path pairs a PNG with hash-bound source and validates downloaded bytes before recovering an editable fence.
- **Supported cloud subset:** delegated native identity, configured organizational SharePoint discovery, same-page Graph updates, selected-page refresh and local offline/recovery behavior. A synthetic O2N-origin page completed an actual O2N ↔ official web-editor roundtrip; this is not a guarantee for arbitrary pages.
- **Recovery:** baselines and outbox state, disjoint merges, retained overlap copies and protected handling of unsupported or inaccessible content.

See the [dated acceptance record](reconstruction/oauth-sharepoint-acceptance.md) for exact tested cases and limitations. Broader tenant/account coverage, all OneNote object types and complete visual/transition parity are not established by that baseline.

## Next: Compatibility And Native Editing

- **Broaden official-origin roundtrips — in progress.** Exercise pages created and edited in official OneNote, including text, tables, images, attachments and empty editor/caret blocks. Preserve untouched remote objects while allowing neighboring supported edits. Completion requires native edits visible in the official editor, an official return edit, unchanged page identity and actual resource preservation; local regression coverage alone is insufficient.
- **Make recovery understandable.** Explain pending local work, protected content, stale diagram source and unresolved overlaps without implying that an access error means deletion. Reopen and reconnect should retain both the user's work and the remote version needed for resolution.
- **Keep OneNote-style interactions consistent.** Verify inline creation/naming, keyboard focus, selection, undo, menus, light/dark appearance, resizing and view transitions across implemented workflows. Add focused accessibility and VoiceOver checks; screenshots do not establish behavioral parity.
- **Expand the editing subset deliberately.** Improve table structure operations, cloud title/hierarchy mutation and persisted rich formatting only with explicit conversion and roundtrip tests. Disabled controls should remain accurate until those behaviors are supported.

## Planned: Markdown And Review Tools

- **Code-oriented editing.** Improve fenced-code authoring, language presentation and keyboard workflows while keeping native rich writing as the normal experience. Preserve source, selection and undo across modes.
- **Anchored annotations/comments.** Define local comment threads, resolution and version/context-aware anchors. External edits that make an anchor ambiguous must leave it visibly unresolved. General shared review comments are not currently shipped.
- **Metadata portability.** Define a versioned export/import representation for O2N enhancements and recovery state. Test ordinary official-client edits, missing companions, changed previews and fresh-device recovery before claiming broader preservation.

The [compatible-client article](docs/compatible-onenote-client.md) explains why these features need more than rendered HTML or raw selection offsets. Implementation must preserve the existing [document architecture](reconstruction/markdown-first-architecture.md) and [native-shell contract](specs/native-shell.md).

## Exploratory: Shared Extensions And Personal Workflows

- **Shared extension metadata:** evaluate attachments or a separate service for participating clients' annotations and richer source state. Decide identity, permissions, offline behavior, migration and reconciliation before selecting storage. No shared metadata service is provisioned.
- **Web participation:** investigate a browser extension over the official web client or an independent web client using OneNote content plus extension metadata. Neither is implemented; unchanged official clients cannot be assumed to display O2N-only annotations.
- **Local customization:** consider Vim-style bindings, note-specific deep links and opt-in AI assistance. Preserve native editing and make any external data transfer explicit.
- **Own-backend option:** a possible future product direction, not the current plan. It would require independent sync, revisions, permissions, backup/recovery and a maintained bridge if official OneNote collaboration remains a requirement.

These ideas need separate designs and validation. They are not reasons to delay reliable local editing or the supported OneNote path.

## Distribution And Release Work

- **Public app packages:** include O2N's MIT notice with dependency notices, verify source revision/signatures/checksums and complete the release gate before publishing a binary.
- **Signing and onboarding:** improve stable signed/notarized distribution and first-run account setup. Ad-hoc development builds can require renewed Keychain approval; broader account/tenant configurations need their own acceptance.
- **One public repository:** keep development, contributions, tags and reviewed GitHub Releases here. Retain the latest fictional demo screenshot and reproducible demo notebook.
- **Legacy material:** review the publicly reachable Microsoft research/tree/history/LFS boundary. Any destructive cleanup requires a backed-up, explicitly authorized plan; MIT and a source-only release asset do not clear the existing history.

Follow the [release guide](PUBLIC_RELEASE.md). There are no packaged GitHub releases yet; the source build is the current way to try O2N.
