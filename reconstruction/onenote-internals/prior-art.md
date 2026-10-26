# Parser And Graph Prior Art

This source-level comparison assesses the four distinct GitHub projects supplied by the user against OpenOneNote's file-import, storage-research, and synchronization goals; sources were refreshed on 26 October 2026.

## Recommended Use

| Project | Verified contribution | Boundary | License / inspected revision |
| --- | --- | --- | --- |
| [pyOneNote](https://github.com/DissectMalware/pyOneNote) | `Header`, `FileNodeList`, node traversal, properties, embedded-file and JSON helpers | Best supplied lead for binary-format study; no demonstrated writer/native sync | Apache-2.0; `228dc663e8433ad8157d2813409428f2e9850338` |
| [one-extract](https://github.com/volexity/one-extract) | `.one` header check, embedded-file marker/size extraction, title metadata, password-protected object support | Useful extraction cross-check; signature scanning does not reconstruct the complete revision graph | BSD-3-Clause; `8a92d8e19c1b4ce342aba7863b4d96713cb624ca` |
| [OneNoteAnalyzer](https://github.com/knight0x07/OneNoteAnalyzer) | Page/text/image/link/file output and PNG rendering through `Aspose.Note.Document` | Comparison-output candidate; parsing/rendering internals belong to a separate dependency | Wrapper MIT; `9148708d5d65e3d00cb63ad627f07e8d15b5ac11` |
| [onenotemcp](https://github.com/eshlon/onenotemcp) | Delegated Graph list/read/create/PATCH and HTML processing examples | Graph adapter examples, not CSI or Mac-cache implementation | MIT; `b5009c847c906bd6312ac96e817652c18431fa79` |

These are **source observations**, not results from running the projects against this user's notes. No upstream binary, dependency installer, test document, or extracted payload was executed. No source was added as an application dependency.

## What The Code Establishes

- **pyOneNote:** `OneDocment` constructs a `Header` and root `FileNodeList`, recursively visits nodes, and exposes property/file helpers. Use it alongside MS-ONESTORE to compare node dispatch, chunk references, and malformed-input handling in a future independent read-only importer. Its README's development statement does not establish current maintenance: the inspected branch head is dated March 2023. [Pinned implementation](https://github.com/DissectMalware/pyOneNote/blob/228dc663e8433ad8157d2813409428f2e9850338/pyOneNote/OneDocument.py)
- **one-extract:** the implementation checks the full 16-byte `.one` signature and scans for embedded-file/title markers. This complements a structural parser but cannot establish which historical object belongs to the current revision merely because bytes match a marker. Its README explicitly describes an interim extractor. A future differential fixture should compare exact file bytes, offsets, and metadata while independently resolving current-revision membership. [Pinned implementation](https://github.com/volexity/one-extract/blob/8a92d8e19c1b4ce342aba7863b4d96713cb624ca/src/one_extract/one.py)
- **OneNoteAnalyzer:** `Program.cs` calls Aspose for document parsing, child-node queries, and PNG output. The open wrapper is informative about extraction goals, but it is not an independently implemented ONESTORE decoder. Assess Aspose licensing/runtime separately before using it as a reference-output generator; the wrapper's MIT license does not cover that dependency. [Pinned implementation](https://github.com/knight0x07/OneNoteAnalyzer/blob/9148708d5d65e3d00cb63ad627f07e8d15b5ac11/Program.cs)
- **onenotemcp:** the implementation targets `graph.microsoft.com/v1.0/me/onenote`, includes body replacement/append operations, defaults to the Graph Explorer client ID, and writes an access token to `.access-token.txt`. Reuse the operation ideas only behind our legitimate app registration and sanctioned refresh-capable authentication. Its body-level edits are not evidence of lossless positioned-container, ink, revision, or attachment preservation. [Pinned implementation](https://github.com/eshlon/onenotemcp/blob/b5009c847c906bd6312ac96e817652c18431fa79/onenote-mcp.mjs)

## Discord And Remaining Gaps

**Unassessed:** the supplied Discord channel could not be retrieved through the available web tool, and no Discord connector was available. No claims are based on its contents; no message was sent, membership changed, or authenticated browser session disturbed.

**Decision:** prioritize the two Python projects as source references and future differential validators for synthetic `.one` fixtures. Keep production/runtime research tooling Swift. None of these four inspected projects demonstrates native Mac `.bin` decoding, CSI/FSSHTTP transport interoperability, server capability access, or complete two-way fidelity. They reduce the file-understanding workload; they do not close the live-sync evidence gaps.
