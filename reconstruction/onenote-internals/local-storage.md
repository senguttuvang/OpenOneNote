# OneNote Mac Local Storage

This document records read-only filesystem/header/schema observations from OneNote 16.114.1 on 26 October 2026, distinguishing the live cache, backups, indexes, and shared-extension data.

## Observed Root

**Observed:** the relevant sandbox support root is:

`~/Library/Containers/com.microsoft.onenote.mac/Data/Library/Application Support/Microsoft User Data/OneNote/15.0/`

The `15.0` storage directory name coexists with app version `16.114.1`; it must not be treated as the installed application version. No account directory names, notebook filenames, database rows, or note text were exported.

| Child | Observation | Interpretation |
| --- | --- | --- |
| `cache/` | 10,887 `.bin`, 1,267,391,463 bytes; 22 open descriptors in the running app | Active cache association is observed; complete allocation/transaction format unknown |
| `Backup/` | Metadata-only enumeration: 664 `.one`, 649,930,197 bytes | Local backup files; not the active `.bin` store |
| `FullTextSearchIndex/` | 13 SQLite `.db`, 60,014,592 bytes | Search-derived data, schema includes text and object/revision references |
| `AccessibilityCheckerIndex/` | 13 SQLite `.db`, 22,630,400 bytes | Accessibility-derived data |
| `MasterIndex/` | One SQLite `.db`, 20,480 bytes | Index progress/plugin metadata |
| `NoteTags/` | Four SQLite `.db`, 65,536 bytes | Tag schema with local dirty-state metadata |
| `RecentSearches/` | One SQLite `.db`, 16,384 bytes | Recent-search metadata; no search rows read |
| `ServerListings/` | Five files, 34,675 bytes | Bounded scan found no synthetic notebook-title marker |

Source: [directory totals and deduplicated schema](../../research/sync/runtime/storage-schema.json), captured `10:41:20Z`; [native descriptors](../../research/sync/runtime/native-observation.json), captured `10:44:02Z`. Counts are observations of a running application, not an atomic snapshot or completeness guarantee for every account.

## Header Evidence And Scope Difference

- **Observed — conservative header probe:** it excluded symlinks, hidden files, and paths containing credential-related words. It inspected 531 `.one` files: 529 had the first eight bytes of the documented `.one` type GUID and two were empty. The broader `Backup` metadata enumeration counted 664. These differently filtered counts are not evidence that backups grew or that files were deleted.
- **Specification:** the complete 16-byte `.one` file-type GUID is `{7B5C52E4-D88C-4DA7-AEB1-5378D02996D3}`. A matching eight-byte prefix is a format lead, not full ONESTORE validation. [Header](https://learn.microsoft.com/en-us/openspecs/office_file_formats/ms-onestore/2b394c6b-8788-441f-b631-da1583d772fd)
- **Observed — cache:** 26 `.bin` files began with a ZIP local-file-header signature; 10,861 were unclassified by the small magic allowlist. No cache payloads were copied or parsed. Unclassified does not mean encrypted, compressed, or a valid ONESTORE container.
- **Observed — before/after:** the conservative aggregate header/file-size results were identical at `10:38:40Z` and `10:43:16Z`, spanning initial Graph creation/append and unsuccessful attempts. No per-file content hashes or mtime comparison was performed; unchanged aggregate counts/sizes cannot exclude in-place updates. [Before](../../research/sync/runtime/storage-before.json), [after](../../research/sync/runtime/storage-after-graph.json)

## SQLite Responsibilities

**Observed — schema only:** immutable read-only opens examined 32 persisted databases; no live WAL contents or application rows were selected.

- **Full-text entities:** `GOID`, `GUID`, `GOSID`, `ParentGOID`, `ContentRID`, `RootRevGenCount`, timestamps, title, and enterprise identity columns. `PageElements` includes `GOID`, `Text`, `Jcid`, and an entity reference; FTS tables have segment/content/docsize/stat tables.
- **Master index:** `IndexedRID`, `PendingIndexRID`, `IsResetting`; plugin schema versions and pending schema transitions.
- **Tag metadata:** `IsLocalDataDirty`. This is evidence of tag-local dirty state, not proof that this database is the notebook synchronization outbox.
- **Accessibility entities:** object identity and `RootRevGenCount`, with violation/element mappings.

**Inference:** the app derives multiple indexes from a separate object/revision store. Deleting an index or editing its `Text` columns would not constitute a supported notebook edit. This investigation performed neither operation. Immutable mode deliberately ignores WAL state; it makes no claim about current transaction consistency or recovery.

## Other Observed Paths

`~/Library/Containers/com.microsoft.onenote.mac/Data/Library/Caches/` contained SQLite, binary-plist, and opaque cache files. The header probe found one 49,152-byte `.db` and one 4,096-byte `.sqlite`; their application rows were not inspected.

`~/Library/Group Containers/UBF8T346G9.Office/OneNote/ShareExtension/` contained an XML plist in the bounded probe. The shared Office root is not interchangeable with the sandbox's main note store. Unrelated Office identity/account files were excluded.

**Untested:** reconstructing a native page from cache bytes, validating complete backup revision trees, restoring a backup, file-to-page mapping, fsync ordering, and crash recovery. No personal cache/backup was copied into this repo or an index.
