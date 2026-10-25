# Native menu and ribbon comparison

The user rejected the 0.2.0 interface because whole menu families and ribbon controls were missing. The reference is the running OneNote Mac 16.114.1 UI plus the supplied screenshots. Private account/notebook content remains outside this repository.

## Observed differences addressed

- Native menu bar: expanded from five reduced menus to the ten reference families, preserving nested entries and separators. `specs/observed-menu-labels.json` records sanitized live menu labels; native-menu tests require each label to remain present in its matching family. App identity is OpenOneNote; macOS provides Services and dynamic window entries.
- Home: restored clipboard Format, list/indent/clear formatting, subscript/superscript, highlight/font colour menus, paragraph alignment, the full style/tag galleries, Dictate, Tell me, sync status, Share and quick-access customization.
- Insert: retained Table, File, Printout, Picture, Screenshot, Link, Equation, Date/Time, Shapes, Audio Recording, Meeting Details and Stickers.
- Draw: retained Text Mode, Lasso Select, Insert Space, Eraser sizes, Pen, Marker, Highlighter, colour choices and thickness controls.
- View: retained New Window, background, versions/deleted notes, zoom controls, password protection, paper colour/style, page title and authors controls.
- Navigation: restored Search, Notebooks, Recent Notes, account position, selected rail marker, notebook dropdown, hide-list and sort controls.
- Real window lifecycle: the live app screenshot exposed an additional 28pt title-bar safe area that the old borderless preview hid. The hosting view now explicitly excludes that inset in its full-size-content window. Initial keyboard focus moves to the native text editor instead of selecting the font field.
- Readability: title underline width and ribbon group placement now follow the reference. Font-size UI uses OneNote's 14-point display scale (18.67 native drawing points). Calibri is used when available; otherwise the actual system font is shown without an internal font identifier. Microsoft font/bitmap assets are not app dependencies.

## Availability and verification boundaries

Unsupported commands stay visible and disabled with a tooltip; retaining their UI is not implementation of their behavior. Local native formatting, format copying, indentation, headings, plain-text tag markers, dates, lists/tables, search scopes, window creation, view toggles, zoom and paper-line rendering are implemented. Clear Formatting and format copying preserve table/list structure and link destinations.

Cloud notebook/account operations, section groups, import, advanced table edits, media/ink/audio, equation rendering, protection, history/deleted notes, export/printing and update services remain unavailable. Tags are local text markers, not OneNote tag identities. No unsupported action is routed to a destructive substitute.

OneNote was inspected through the actual application's accessibility tree and screenshots. The actual independently identified OpenOneNote Inspection app was launched with a synthetic notebook and prohibited activation, captured through computer use, and its native File menu checked against the reference. Full-size and compact renders cover all four tabs. This supports the measured geometry and retained observed controls; exact pixel/behavior parity is not claimed.

Reference split-button inspection revealed that primary Paste executes the action rather than opening its menu. That action was immediately undone; no reference content is included in fixtures. Full screen and Home were restored. Coordinate targeting of reference ribbon arrows returned `noWindowsAvailable` in full screen; complete arrow-gallery enumeration requires a permitted temporary window/focus change. Do not treat unobserved palette/gallery internals as verified.

## Repeatable native checks

```sh
swift run openonenote-dev check
swift run OpenOneNoteMac --render-interface scratch/interface-review
swift run openonenote-dev inspection-app
"dist/OpenOneNote Inspection.app/Contents/MacOS/OpenOneNoteMac" --inspect-ui scratch/new-inspection/notebook.json
```

Inspection refuses an existing notebook path, uses a separate bundle identifier, orders its owned window behind the user's work and does not activate. Close only that agent-owned process after review. Normal app packaging remains separate.

Paired actual screenshots were subsequently captured for Insert, Draw, View and Home, restoring Home afterward. They exposed additional grouping differences: vertical file/media tools, an abbreviated shape strip, dot-only thickness previews and compact View controls. The follow-up source uses the reference's horizontal file/media row, all14 shape previews in two rows, five labelled stroke samples, and large View tiles with the zoom field above Reset Zoom/Page Width. Unsupported controls remain disabled. Original artwork, font availability and unobserved dropdown internals remain differences; these changes do not establish full-match acceptance.
