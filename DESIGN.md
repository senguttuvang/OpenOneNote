# OpenOneNote Native Editor Design

This document records the implemented local-first Mac editor design, following the user's OneNote-style workflow and standing bright-blue visual direction.

## Writing First

The domain is notebooks, sections, pages, text containers, selection, and a spacious writing canvas. The signature is a page with independently movable/resizable native text containers, kept in the familiar notebook → section → page hierarchy.

The user confirmed local editing first, with import/sync later. The first screen concentrates on writing, navigation, and working native formatting controls.

## Native Structure And Tokens

- **Sidebar:** 220pt blue rail; notebook name, sections, New Section, and local-storage identity.
- **Page list:** 230pt pale-blue panel; editable section title, New Page, page titles, and short text previews.
- **Writing surface:** white; 48pt content inset; 28pt semibold page title; native 18pt body text. Initial text container is 600 × 300pt and can be moved/resized.
- **Palette:** blue `#0878b5`, navy `#18324f`, secondary text `#52657c`, pale canvas `#f5f9fe`, selected page `#e4f2ff`, white paper. Sidebar labels remain white. The first alpha uses light appearance.
- **Density:** 8pt rhythm, 12–20pt navigation padding, 14pt page previews, 16pt primary navigation, restrained 1pt container outlines. No decorative shadows or entrance animation.
- **Icons:** system symbols in the interface; an independently drawn blue-book application icon. Microsoft assets remain research-only.

## Editing And States

AppKit `NSTextView` owns caret/selection, input, clipboard text, font panel, and native text undo. Bold/italic are explicit native text-view actions with persistence and undo tests. SwiftUI owns navigation, naming, toolbar composition, and container geometry controls.

Autosave waits 300ms after edits. Save/close/quit flushes pending edits. Opening invalid JSON or invalid RTF preserves the original file and shows an error. Failed saves keep the in-memory model available for Retry. Text undo is scoped to the active page and resets on page/section navigation.

The window minimum is 960 × 640pt. The canvas intentionally scrolls horizontally when the user-resized document geometry exceeds the viewport; resizing the window does not rewrite stored note positions or widths. UI controls remain inside the window at compact width.

## Verification Scope

Real native views are rendered in hidden windows at 1280pt and 960pt widths with prohibited app activation. Native text edits, formatting, undo/redo, persistence, and failure recovery are exercised programmatically. These checks preserve the user's foreground app.

Complete visual parity against Microsoft OneNote and manual VoiceOver/full keyboard navigation have not been verified. Ink, attachments, rich tables, cross-container selection, zoom behavior, import, and sync are future capabilities.
