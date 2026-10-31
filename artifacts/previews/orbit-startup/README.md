# Orbit Startup Demo Screenshots

These images show the actual O2N macOS app with a fictional startup notebook, providing a readable product example for the main README.

- [Markdown onboarding](markdown-onboarding.png): the README's lead image, with Markdown source, rendered requirements and an offline Mermaid onboarding diagram. This is the maintainer-supplied screenshot, preserved unchanged at its original **1716 × 1115 pixels**, including the macOS menu bar.
- [Product brief](product-brief.png): the normal native rich editor, notebook sections, product pages, a small metrics table and weekly priorities. This is an unmodified lossless app-window PNG at native Retina resolution: **3456 × 2168 pixels** for a 1728 × 1084-point window.

Both screenshots were captured on 31 October 2026. The product-brief capture used installed program source `4b520be4fce91d046112043081088612e9d139c6`, also present in its capture branch's main baseline `2809a95`. Its temporary fixture copy used a distinct application identity and no OAuth callback registration; its UI and program code were unchanged. That capture did not replace the installed app or access existing notebooks/accounts. The Markdown screenshot shows the installed app opened with the separate local Orbit demo vault.

Orbit, its pages, metrics, targets and planning decisions are fictional sample content. They are not customer data or O2N performance claims. The screenshots illustrate the preview's current UI; they do not establish full OneNote parity or additional cloud acceptance.

## Recreate The Notebook

From an O2N source checkout:

```sh
swift run --jobs 2 openonenote-dev demo-vault /tmp/o2n-orbit-demo
swift run --jobs 2 openonenote-dev app
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --vault /tmp/o2n-orbit-demo
```

The output directory must not exist. The generator uses the public Markdown vault API to create 17 local-only pages in six sections, with no Microsoft configuration or network writes. Select **01 Product brief** for the normal editor; select **02 Onboarding flow**, then the Markdown icon and **Split**, for the second view. Use a new destination for another copy rather than deleting or overwriting existing notes.
