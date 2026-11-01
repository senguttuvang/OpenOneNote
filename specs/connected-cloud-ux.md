# Connected account, notebook browser and sync UX

Observed live in official OneNote for Mac on 1 November 2026: the avatar opens an anchored account popover with identity, Connected Services, add-service and Sign Out. Add a Service opens a separate Connected Accounts / Add Storage Account surface. Open Notebook presents a large location sidebar and horizontal columns. Recent Folders, Personal OneDrive, work OneDrive and Sites are distinct locations. Navigating a site then Documents appends library/folder/notebook columns. Open stays disabled until a notebook is selected. Refreshing remains visible while cached rows are usable. Cancel returns to the existing note. The toolbar cloud control opens a compact Sync status popover with Page saved and Page last synced just now.

## Scope and acceptance

- Implement anchored account and sync popovers, a storage manager and a large column browser. Use existing native colours/type and system symbols, without copying Microsoft artwork.
- Display only O2N's securely restored SDK identity and services it can actually access. Never infer a connected account from a configured Graph client, email typed into a field, or another app's account list.
- Browse OneDrive folders, SharePoint sites, document libraries and notebook packages through read-only Graph contracts. Preserve account/root/path identity and clear descendant selection immediately when an ancestor changes. Cancel stale async results; provide loading, empty, permission and retry states.
- Notes-only saved consent remains usable for existing notebook roots. Additional storage browsing consent is requested only through explicit Connect Storage, in a human-owned Microsoft sign-in flow. Do not silently expand permissions. The existing single-tenant registration does not support personal account sign-in; label that capability accurately instead of simulating success.
- Opening a notebook lists its real sections/pages in ordinary navigation. Do not download or edit all notebook contents merely to populate navigation. Opening a page reuses existing same-page NoteSync/recovery and account checks.
- Sync status distinguishes locally saved, pending upload, syncing, synced and failed/recovery. Last synced is recorded only after successful content reconciliation/readback, never from a local save, metadata poll or browse operation. Retry invokes the current page sync, and recovery remains available.
- Keep ordinary local creation, rich editor, source ribbon, independent undo and recovery intact. Cloud creation remains a separate capability; do not silently map local creation onto cloud writes.

## Boundaries and verification

MarkdownNotes owns portable ledger timestamps. OneNoteGraph owns SDK account projection and validated/paginated read-only storage operations. MarkdownEditor owns cancellable browser state and native presentation. No account cache, process memory or runtime traffic from the official app is inspected. Private screenshots, names, tenants, IDs, site inventories and diagnostics stay outside tracked source.

Use injected transports for deterministic browse/account isolation, pagination, stale-response, failure and hierarchy tests; hidden/prohibited native renders for layouts/popovers; full exact-worktree local gate. Install a signed committed build with centralized backup only under the released lease, then visually exercise synthetic account/browser/page/sync paths. A screenshot does not establish transition timing: semantic observations verified popover/window and appended-column transitions; exact duration/easing remain unmeasured.
