#!/bin/sh
set -eu
bundle='/Applications/Microsoft OneNote.app'
root=$(git rev-parse --show-toplevel)
destination=${1:?Pass a new output directory}
case "$destination" in /*) ;; *) destination="$root/$destination";; esac
if [ -e "$destination" ]; then echo 'Output exists; evidence is immutable' >&2; exit 1; fi
mkdir -p "$destination"
plutil -convert xml1 -o "$destination/ribbon.xml" "$bundle/Contents/Resources/onenote_mac.ribbonb"
nm -arch arm64 -m "$bundle/Contents/Frameworks/mso40ui.framework/Versions/A/mso40ui" > "$destination/mso40ui-symbols-arm64.txt"
otool -arch arm64 -v -s __TEXT __objc_methname "$bundle/Contents/MacOS/Microsoft OneNote" > "$destination/objc-selectors-arm64.txt"
if xcrun ibtool --objects --hierarchy --connections --output-format xml1 "$bundle/Contents/Resources/ONFishbowlViewController.nib" > "$destination/ibtool-compiled-nib-result.xml"; then
  echo 'ibtool decoded the selected nib'
else
  echo 'ibtool rejected the compiled nib; error XML retained' >&2
fi
