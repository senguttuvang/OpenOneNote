# OpenOneNote Shell with Native Rich Editing

The OneNote for Mac reference governs the application shell. Markdown is the portable document format and an integrated editor mode; it does not replace the ribbon or notebook hierarchy. The earlier generic split workspace is superseded. Legacy canvas data and its editor remain preserved.

## Current workspace

Section creation is inline: Add section, File → New Section and the keyboard shortcut create/select a unique section immediately and select its name in the navigation row. Return commits and moves to the new page title; Escape keeps the generated section name. The New Section naming sheet is removed from the presentation model entirely.

The title/actions, tabs and ribbon occupy 148pt. A 47pt application rail precedes the notebook/section and page columns, measuring 300/250pt at wide sizes and 250/169pt at compact sizes, following the 31 October reference. Home, Insert, Draw and View preserve the observed groups. A code icon inside Home reveals Markdown Write/Split/Read in the same page; there is no Markdown tab. The ordinary canvas is proportional native rich editing below an editable local title and underline. Add page immediately creates/selects a blank page and focuses its title, without a name dialog. The title persists independently of body headings. Cloud rename is unavailable and its title is read-only. At compact widths rich text reflows; source Split permits horizontal scrolling. Navigation can be hidden and its widths adjusted from View. System appearance chooses the measured dark neutrals or light equivalents, with purple actions and accessible blue headings/links.

Account and Open Notebook dialogs contain ordinary sign-in and discovery flows. Advanced client/tenant/redirect/root configuration lives only in Preferences. The sync detail dialog provides scrollable baseline/local/remote comparisons and the existing explicit recovery actions. Both notebook-wide sync labels are retained but disabled: only Sync This Page invokes the current backend. New pages/notebooks/sections are local, and creating a page while viewing a Microsoft notebook moves to On My Mac. Moved Markdown remains relinkable from the page context menu.

The actual native menu bar preserves the observed families and labels, with unavailable features disabled rather than substituted. The rich projection supports paragraphs, headings, bold/italic/strikethrough, links, inline code, simple lists, native table insertion and cell text editing over the existing portable semantic tree. Complex blocks retain source and reject rich changes. Both NSTextViews remain mounted, with separate undo managers so refreshing a hidden projection cannot erase active undo. Find/Replace, keyboard shortcuts, zoom, window actions and native clipboard operations supplement the reference shell. Font/size persistence, underline, arbitrary colours, spatial objects, table structural commands, ink, recording, dictation and sharing remain unavailable; this is not full feature parity. The supplied still image does not establish official transition timing.

Local source saves immediately and survives offline operation. The auth foundation owns selected-page read-only adaptive refresh, focus/wake behavior and full-content deadlines; see its acceptance record. Background refresh never pushes edits or opens consent. A single busy operation disables source changes and supports cancellation. Actual errors remain visible in the status area; failed saves prevent window termination. Native undo is scoped to the current note.

Verification uses prohibited activation and hidden owned windows. The local gate exercises selection-aware Unicode formatting, native undo/reopen, hierarchy preservation, observed menu labels, mode transitions and source-view identity, actual ribbon/mode/dialog renders in both appearances, local diagram PNGs and malformed diagram rejection. Synthetic content follows the reference's structure without reproducing client notes. Packaged checks repeat the native behavior with copied resources and nested signatures. Live Graph readback, native authentication and official OneNote round-trip acceptance remain separate evidence owned by the cloud session. Reference layout reconstruction does not establish pixel-perfect or complete interaction parity.

## Preserved legacy canvas reference

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

## Integrated legacy interface history

The preserved JSON/RTF canvas also retains the legacy observed menus, native galleries, command routing and hidden interface render verification from PR4. This mode is selected explicitly with --legacy or --notebook. Its historical inspection mode uses a separate bundle identity and never registers the production OAuth callback. These additions do not replace the default rich editor or establish cloud or full OneNote parity.
