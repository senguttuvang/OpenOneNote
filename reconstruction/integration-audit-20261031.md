# Branch reconciliation, 31 October 2026

SenG requested review and integration of all preserved branch/worktree work. Other worktrees and branch refs remain intact. Integration uses the cloud session's exclusive feature worktree and GitHub; canonical main receives only fast-forward synchronization. GitHub Actions remains disabled.

## Previously delivered histories

- `feat/research-foundation` at `a265824` has tree `797412f6e01e0541c6c9dea90325a66192ec5682`, exactly the tree of the already merged PR1 result `a2e39814`. Its original history is reconciled with an ancestry-only merge. Retired shell scripts and the removed Actions workflow are not restored.
- `feat/local-first-editor` at `cf5792d` has tree `5f584ea5ac85c791b2116158c18edb8cb241e06b`, exactly the tree of already merged PR2 result `f227af1`. Its ancestry-only merge preserves all subsequent editor and Swift tooling changes.
- The Markdown, OAuth, storage recovery, native shell and October 31 rich editor histories are already ancestors of main through PR9 (`7d866d1`). PR11 (`142278c`) additionally delivers inline section creation; its exact implementation is merged into this cloud branch.

## Unique legacy interface work

PR4 at `3712f26` contains ten unique commits. A normal feature merge preserves its legacy JSON/RTF menus, ribbon galleries, command routing, table paragraph boundary correction, search/view controls, tests, historical LFS packages and synthetic captures. The current rich editor and Markdown ribbon remain the default; legacy entry points remain explicit.

Conflict review retained current authentication, resources/licenses, safe installation and all native cloud commands. The separate inspection package uses its own bundle identity and does not register the production OAuth callback. Hidden gallery rendering is added to the local gate. Current README and verification receipt are retained rather than replaced by historical claims that sync is absent. The original legacy receipt is preserved under `artifacts/previews/interface-0.3.0/verification.json`.

## Native cloud repair evidence

The installed `190a026` eventually completed native PKCE callback, exchange and private Keychain save. Read-only diagnostics then reused that identity in a fresh process: personal notebooks succeeded, while the configured SharePoint notebooks failed with HTTP403 / OneNote40004 and no delegated `Notes.ReadWrite.All` scope. Microsoft documents 40004 as insufficient scope and requires delegated shared-notebook access for this target. Only that delegated permission was added to the dedicated registration, retaining the prior personal declaration and zero application roles/secrets. No tenant-wide consent was granted.

The new adapter forwards SDK callbacks synchronously to the main actor and rejects silent reuse of insufficient personal scope. Installed `5c8976a` includes that repair and PR11. Native sign-in completed; fresh-process diagnostics report the required scope and successful personal/configured hierarchy requests. The new synthetic notebook, section and page were created; their immediate open returned HTTP404 /20102. The fixture is retained and retries resume recorded identities. This is not completed bidirectional acceptance; actual official editor writes and preservation checks remain separate.

References: [OneNote error codes](https://learn.microsoft.com/en-us/graph/onenote-error-codes), [shared notebook scopes](https://devblogs.microsoft.com/microsoft365dev/onenote-service-scopes-update/), [create notebook](https://learn.microsoft.com/en-us/graph/api/onenote-post-notebooks?view=graph-rest-1.0).
