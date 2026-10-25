# OpenOneNote Native Editor Design

The 25 October 2026 OneNote Mac screenshot is the visual authority for this native local notebook editor. This replaces the earlier blue/white alpha direction. OpenOneNote keeps its own identity and system-symbol assets.

## Geometry and materials

The reference is 1728 × 1088 pixels. Owned-view previews use one output pixel per logical point for repeatable comparison; a native Retina window still renders at its backing scale. Screenshot measurements are a reference composition, not recovered Microsoft layout constants.

- Top region: 148pt (36pt title/actions, 36pt tabs, 76pt ribbon), reference approximately 149px.
- App rail: 47pt. At widths of 1400pt and above, sections are 250pt and pages 301pt: canvas starts at x598. Below that threshold, columns are 200pt and 220pt, leaving a usable scrollable canvas at the 960pt minimum.
- Notebook header: 45pt; section rows 36pt, page rows 56pt; bottom creation rows 44pt.
- Page title: 24pt, 48pt left inset, 22pt top inset, thin underline. Synthetic reference container: x72 in canvas, y32 below the title region, width914, height820. Existing notebook geometry is preserved.
- Canvas `#202020`, navigation approximately `#242424`, ribbon `#272727`, selected row approximately `#3b3b3b`, rail `#303030`. Main ink `#ebebeb`, secondary `#adadad`, links/headings `#64aee5`, purple action tint. Secondary text contrast against navigation is above 6:1.
- Body uses installed Calibri at 18 native points, falling back to the system font. Explicitly stored RTF fonts/colors remain intact. The reference's ribbon displays 14; native text metrics and the reference application's display scaling differ. Text size is visually compared, not claimed as exact font parity.
- Compact ribbon scrolls horizontally. The document canvas scrolls independently in both directions. Resizing the window never rewrites saved document coordinates.

## Interaction

Home provides native clipboard commands, bold/italic/underline, strikethrough, highlight, blue text color, font family/size, paragraph alignment, list paragraph styles, headings and text-container creation. Insert provides text containers, a 3×2 editable bordered native text table and URL application to selected text. Draw explicitly states that ink is unavailable. View reports the current document scale; zoom is not implemented. Sharing and dictation are not presented as working features.

The formatting controller holds a weak reference to the selected native text view while ribbon controls take focus. Selection attributes update the ribbon. Page navigation clears that reference and native text undo targets. Mixed selections display their first run's attributes. Lists use NSTextList paragraph metadata; advanced list numbering/indent/return behavior remains limited by TextKit and requires further validation.

The text container has a 9pt move bar and a bottom-right resize handle. Existing native input, spelling, clipboard, keyboard shortcuts, text undo/redo, 300ms autosave, save-error Retry and corruption preservation remain in place. Tables use NSTextTable blocks in RTF; original research assets never enter the application.

## Verification and limits

Render real SwiftUI/AppKit views at 1728×1088, 1280×800 and 960×800 with prohibited activation and hidden owned windows. Inspect the reference and compact images, including crops of navigation, ribbon and note text. Native integration tests cover selection formatting, links, list metadata, heading size, table insertion, undo/redo and RTF save/reopen. No Microsoft OneNote interaction, full keyboard traversal or VoiceOver test has run.

This is a close layout reconstruction with a functional local editing slice. It is not pixel-perfect or full feature parity: ribbon group coverage, tags, rail tools, text metrics, table controls, ink, attachments, zoom, cross-container selection, import and synchronization remain different or unsupported. Synthetic fixture content shares the reference's structure without reproducing client text.
