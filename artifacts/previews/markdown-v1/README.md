# Markdown workspace verification

Program source: `34c98091c60c0a22be74e93e0dfc3bee88164fce`, version 0.3.0 build 4.

The 1280/960 PNGs capture actual native source and reading views in hidden windows with prohibited activation policy. `diagram.png` is real output from the bundled offline Mermaid renderer; malformed input was separately rejected. The editor screenshot taken during diagram loading is excluded from this evidence set.

`swift run --jobs 2 openonenote-dev check` passed 55 tests, release build, hidden native Markdown and legacy edit/undo/save/reopen, native renders, diagram PNG/rejection, CLI rejection, evidence tamper rejection and authored whitespace checks. `verify-app` passed against the packaged app; deep/strict signatures and app-local MSAL dependency loading were verified. Archive SHA-256 and gzip validation passed.

A real delegated CLI Graph probe at the same committed source passed same-page formatting/table/image readback, diagram PNG/source attachment upload and fresh-vault fence recovery, remote refresh, offline reconnect, disjoint merge, overlap preservation and remotely changed preview protection. Only newly created named synthetic fixtures were written, retained without deletion. IDs, account metadata, payloads and local recovery stores are excluded. Images used documented data URLs and source attachments used UTF-8 multipart; this does not prove native MSAL or native binary transport.

Native Microsoft sign-in and full native cloud acceptance remain pending an approved Apple developer signing identity/profile with O2N's private Keychain entitlement, then human sign-in. The ad-hoc app detects the missing capability before accessing credentials. No native Microsoft OneNote visual acceptance is claimed. No account-type breadth or transactional/ETag concurrency guarantee is claimed. GitHub Actions remains disabled.
