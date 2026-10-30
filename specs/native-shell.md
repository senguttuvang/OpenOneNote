# Native OneNote shell with Markdown

The 25 October OneNote for Mac reference governs presentation and interaction. Markdown remains the document format and integrated source mode. This supersedes the generic split workspace described in older Markdown-first material without changing the portable vault, Graph identity, recovery or legacy canvas contracts.

- Keep Home/Insert/Draw/View and the observed menu families and labels. Expose unavailable features as disabled commands. Never map notebook-wide or destructive labels onto a narrower unrelated action.
- Integrate Markdown in the ribbon with Write, Split and Read modes. Preserve the same NSTextView, selection, native undo and file identity across mode changes. Selection-aware formatting must handle UTF-16 ranges correctly.
- Keep notebook, section and page navigation, native keyboard selection, search scope, width adjustment, hide/show controls, page title and reference geometry. Reflow Read at compact widths; permit horizontal scrolling for Split and wide content.
- Follow system light/dark appearance. Use measured reference neutrals, purple actions, blue headings and system symbols. Preserve visible hover/pressed/disabled/focus behavior. No proprietary artwork or client content enters the app.
- Account and notebook discovery belong in native dialogs; advanced registration metadata belongs in Preferences. Keep the auth owner's AppAuth callback/refresh and account identity APIs unchanged.
- Friendly state is a summary; sync and recovery detail preserves the existing explicit source comparison/resolution actions. New documents and hierarchy are local. Current-page sync is explicit; notebook-wide sync remains unavailable.

Acceptance: the exact-branch local check runs native Unicode formatting/undo/reopen, hierarchy/navigation invariants, observed native menu inventory, source-view identity across modes, synthetic hidden renders at 1728/1280/960, all ribbon tabs/modes/account dialogs and both appearances. Package verification repeats the native checks. All native checks prohibit activation and leave windows hidden. Full pixel/feature parity, VoiceOver traversal and live cloud acceptance require separate evidence; synthetic checks do not establish them.
