# OpenOneNote Native Interface Design

The running OneNote Mac 16.114.1 interface and the user's 25 October 2026 screenshots are the visual authority. The user rejected the reduced 0.2.0 interface: retain the whole observed UI rather than hiding unimplemented features. OpenOneNote keeps its own identity and independently composed system-symbol artwork.

## Native geometry

- 36pt title/quick-access row, 36pt Home/Insert/Draw/View tab row, 76pt scrollable ribbon. Title-bar safe-area exclusion is explicit in the actual full-size-content NSWindow, not just the borderless preview.
- 47pt app rail with hide-list, Search, Notebooks, Recent Notes and account positions. Sections250pt/pages301pt at reference width; compact sections200pt/pages220pt. Notebook header45pt, section rows36pt, page rows56pt, bottom creation rows44pt.
- Page title24pt with310pt underline and48pt left inset. Synthetic container starts72pt into the canvas and32pt below the title region, width914pt/height820pt. Saved user geometry is preserved; compact views scroll horizontally.
- Canvas `#202020`, navigation approximately `#242424`, ribbon `#272727`, selected row `#3b3b3b`, rail `#303030`; foreground `#ebebeb`, secondary `#adadad`, links/headings `#64aee5`, purple Share/selection accents.
- Font-size controls use reference14pt =18.67 native drawing points. Use installed Calibri when available; show the actual fallback font when it is absent. Do not embed Microsoft fonts or artwork. Explicit stored RTF fonts/colors remain intact.

## Complete observed controls

`InterfaceCatalog` owns labels and hierarchy; `NotebookMenus` builds actual NSMenus; `RibbonView` composes all four native ribbon tabs. `EditorCommands` shares local actions and view state between them. `specs/observed-menu-labels.json` is the sanitized reference acceptance fixture. Every observed native menu label must remain in its matching menu family, including unavailable actions.

Home retains clipboard/format painter, fonts/sizes, list/indent/clear controls, character formatting, subscript/superscript, colour and alignment menus, style/tag galleries and Dictate. Insert retains table, file/printout/picture/screenshot, link/equation, date/time, shapes, audio, meetings and stickers. Draw retains selection/space/eraser/pen/marker/highlighter/colour/thickness. View retains window, background, history/deleted notes, zoom, protection, paper and title/author controls. Tell me, sync status, Share and quick-access choices remain visible.

Unsupported actions are disabled with an availability tooltip. A retained control is not proof of its underlying capability. All ten menu families and nested observed labels remain visible; macOS supplies Services and dynamic window entries. Never route an unsupported destructive operation to a text-edit action with the same name.

## Local editing and view behavior

NSTextView owns caret, IME, clipboard, spelling and native text undo. A weak formatting target retains selection while the ribbon takes focus. Commands include native text formatting, indentation, headings, format copying, local plain-text tag markers, date/time, native tables and links. Clear Formatting preserves structural table/list metadata and link destinations. Table insertion ensures a paragraph boundary so its first cell survives after ordinary prose.

Search supports page/section/current-notebook scopes. Page title sorting is view-only. Background, paper lines/grid, title visibility, list visibility and zoom do not rewrite stored geometry or RTF. New Window uses the same local notebook session. Native text undo remains scoped to the selected page. Atomic autosave waits300ms; save errors retain in-memory edits for Retry; invalid input preserves originals.

## Verification and remaining scope

Use prohibited activation, hidden owned-view renders and the separately identified OpenOneNote Inspection app. Its actual lifecycle is launched behind existing windows with synthetic data. Live computer-use screenshots exposed and verified the title-bar inset fix; native menu trees verify real menu presence. Reference/inspection captures measured3456×2168 pixels in this session. All four tabs also render at1728×1088 and compact Home at960×800.

The complete native-menu label inventory is a test gate. Full ribbon-arrow palette/gallery enumeration is separate: the background computer-use controller reported `noWindowsAvailable` for coordinate targeting of OneNote's full-screen arrows. Do not claim unobserved dropdown internals are verified. See `reconstruction/ui-comparison-20261025.md`.

Cloud notebooks/accounts, section groups, import/sync, advanced table editing, media, ink/audio, equations, protection, history/recent/deleted notes, printing/PDF export and update services are not implemented. Custom tag identities, complete keyboard/VoiceOver coverage and exact pixel/behavior parity remain unverified. UI retention is broader than implemented capability.
