# How OneNote For Mac Is Built

This report assesses the captured OneNote 16.114.1 (16.114.26102031) using static binary evidence and six bounded Ghidra samples, separating observations from architectural inference.

## Main Conclusion

**A native Mac host with mixed technologies and substantial Office infrastructure.** The evidence supports AppKit/Objective-C and C++ integration, some Swift, React Native modules, and embedded web functionality. There is no standard Electron packaging in the complete captured path inventory. This is not evidence of a pure Swift/SwiftUI application, nor sufficient evidence that it is the same application source tree as Windows.

## Capture Scale

- **20,441 file/link entries:** 20,288 regular files and 153 symlinks; 1,363,426,896 regular-file bytes.
- **124 Mach-O candidates:** magic-byte classified; this count is not a count of independent features or unique frameworks.
- **1,854 distinct Objective-C metadata names**, including classes, protocols, and properties, recovered from the main executable. This is not a class count or language-percentage measurement.
- **Preserved architectures:** x86_64 and arm64. Detailed instruction and pseudocode analysis concentrates on arm64.
- **Observed minimum OS:** the main arm64 `LC_BUILD_VERSION` declares macOS 14.0; SDK 26.4. This pertains to this captured executable, not all historical OneNote releases.

See `extracted/16.114.1/summary.json`, `bundle-inventory.json`, `mach-o-files.json`, and `load-commands-arm64.txt`.

## Native Mac Host: Confirmed

- `dependencies-arm64.txt` imports AppKit, Cocoa, Foundation, CoreGraphics, Accessibility, PDFKit, AVFoundation, WebKit, JavaScriptCore, SQLite, `libobjc`, and `libc++`.
- `objc-metadata-arm64.txt` contains `ONAppDelegate`, `ONMApplication`, `ONPageViewController`, and **`ONPageView` inheriting from `NSView`**. The page view's metadata declares 133 methods and C++ construction/destruction support.
- `decompiled/16.114.1/entry_point.c` calls `NSApplicationMain` after Office initialization. The decompiler warns about indirect calls, but the imported symbol and call target are visible.
- Compiled `.nib` files and `onenote_mac.ribbonb` are bundled. `ribbon.xml` decodes the ribbon as an `NSKeyedArchiver` graph, with `Microsoft.OneNote.Mac`, `kOUIRibbonTabsKey`, and related native Office ribbon keys.

**Implication:** macOS is a real native host; the UI is not simply one website packaged as the app.

## C++ And Office Shared Infrastructure: Confirmed Presence

The executable imports C++-mangled Office functions such as `MsoInitHecd`, `MsoWzLower`, and `HrWriteExact`, and embeds frameworks named:

- **UI/editor:** `CocoaUI`, `FluentUI`, `MicrosoftRichEdit`, `mso20`, `mso30`, `mso40ui`, `mso99`.
- **Rendering/text:** `Gfx`, `MicrosoftFontLibrary`, `dwrite10`, `Uniscribe`, `WLMGraphicsDevice`.
- **Compatibility:** `COMBase`, `OLE`, `OLEAutomation`, `rpcrt4`, `WinCrypto`, `WLMKernel`, `Xmllite`.
- **Cloud/identity:** `MicrosoftCSI`, `MicrosoftCloudServices`, `MicrosoftWebServices`, `ADAL4`, `MicrosoftCredui`.

`strings.txt` also retains C++ source-path strings under an Office source tree, including MSIX packaging code. Paths and imported names establish the presence of these components; they do not expose the original source tree.

**Inference, high confidence:** Microsoft reuses portable Office code and provides Mac-facing infrastructure around it. The Windows-oriented compatibility APIs are consistent with that strategy. They are compiled Mac frameworks here; there is no basis for describing this as running the Windows executable under Wine.

**Unresolved:** exact shared-code percentage, Windows UI reuse, source repository layout, and whether specific OneNote engine modules are identical across Windows and Mac. No Windows package was collected or compared.

## Swift: Confirmed, Scope Not Quantified

The main executable has Swift reflection/type sections and Swift runtime imports. Its imported Swift symbols include `SharedUIKeyboarding_swift_mac.KeytipPreferenceView` and `CocoaUI.LargerControlSurfacesPreferenceView`. The `mso40ui` symbol table also exposes Swift `FRNCallout` and related native controls integrated with React Native bridge types.

**Conclusion:** Swift is used in this build. Neither the presence of Swift sections nor their size measures the fraction of source written in Swift. The evidence does not establish SwiftUI as the main application or editor framework.

## React Native: Confirmed Integration

- Main executable imports `_RCTRegisterModule` from `mso40ui`.
- `CopilotFREUI` declares conformance to `RCTBridgeModule` in Objective-C metadata. This ties a OneNote-side class to the React Native bridge, beyond merely finding a library in a bundle.
- `mso40ui-symbols-arm64.txt` contains React bridge/control symbols, including Swift-native controls taking `RCTBridge` and event-dispatcher types.
- Five `.jsbundle` paths occur in the complete inventory: Office foundation/UI bundles and SDX AppCleaner, AugLoop, and LivePersonaCard bundles. Selected foundation/UI bundles are retained as readable original assets.

**Inference:** some auxiliary/shared Office experiences use React Native. Which ones are active in a particular account/session, and their exact share of the interface, require runtime observation. The two sampled Copilot bridge bodies are no-ops and reveal no substantial product logic.

React Native macOS supports embedding native features into an existing application; it is a different architecture from Electron. [Microsoft's React Native macOS introduction](https://microsoft.github.io/react-native-macos/docs/intro)

## Electron And Web Components

The full captured inventory has **no `Electron.framework`, `app.asar`, or `Chromium Framework.framework` paths**. AppKit startup, native views, and the Office frameworks support the conclusion that this is not a conventional Electron app.

WebKit, JavaScriptCore, `onenote.js`, and other JavaScript resources are present. The top-level `onenote.js` identifies itself as the Office JavaScript API library; it is not the notebook editor's recovered source. These web components may support add-ins and other experiences; their presence alone does not identify the editor's rendering engine.

## What The Page-View Sample Reveals

The selected `ONPageView` initialization candidate (`0x10026dbe8`) invokes a native frame initializer, registers cursor/tooltip/context-menu/page notifications, and constructs an `OIInkInputAdaptor`. Another method (`0x10027424c`) compares points with `NSEqualPoints`, updates stored coordinates, and invokes `updateAffineTransform`.

**Inference:** the native page surface coordinates input, view transforms, and ink integration with other engine components. This supports investigating a canvas/editor boundary for reconstruction. It does not prove the implementation of the entire text engine, ink format, hit testing, or document model.

## Permissions And Runtime Boundaries

The captured entitlements include sandboxing, Office app groups, user-selected files, network client, audio input, printing, and identity-related access groups. Entitlements declare permitted capabilities, not evidence that all are exercised. They do not grant OpenOneNote access to Microsoft's account stores or app groups.

The application signature passed deep/strict verification. Developer ID signing and the absence of an App Store receipt indicate this observed installation is consistent with Microsoft direct distribution; an Office installer was not separately downloaded or compared.

## Limits And Next Evidence

Static capture does not recover editable source, exact feature behavior, complete sync algorithms, or backend services. The compiled NIB decoding attempt failed and its error is retained. Ghidra had no external frameworks loaded and no whole-program analysis; types and call signatures are imperfect.

The next useful experiments use synthetic notebooks: record native navigation and text/canvas interactions; measure coordinates, zoom, selection, IME, undo, paste, and accessibility; compare with an independent implementation. Windows comparison is a separate experiment requiring a versioned Windows artifact and cross-platform symbol/behavior comparison.
