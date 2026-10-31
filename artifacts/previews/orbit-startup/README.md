# Orbit Startup Demo Screenshot

This image shows the actual O2N macOS app with a fictional startup notebook, providing a readable product example for the main README.

- [Markdown onboarding](markdown-onboarding.png): the README's lead image, with Markdown source, rendered requirements and an offline Mermaid onboarding diagram. This is the maintainer-supplied screenshot, preserved unchanged at its original **1716 × 1115 pixels**, including the macOS menu bar.
The screenshot was captured on 31 October 2026. It shows the installed app opened with the separate local Orbit demo vault.

Orbit, its pages, metrics, targets and planning decisions are fictional sample content. They are not customer data or O2N performance claims. The screenshot illustrates the preview's current UI; it does not establish full OneNote parity or additional cloud acceptance.

## Recreate The Notebook

From an O2N source checkout:

```sh
swift run --jobs 2 openonenote-dev demo-vault /tmp/o2n-orbit-demo
swift run --jobs 2 openonenote-dev app
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --vault /tmp/o2n-orbit-demo
```

The output directory must not exist. The generator uses the public Markdown vault API to create 17 local-only pages in six sections, with no Microsoft configuration or network writes. Select **02 Onboarding flow**, then the Markdown icon and **Split**, for the pictured view. You can also select **01 Product brief** to try the normal editor. Use a new destination for another copy rather than deleting or overwriting existing notes.
