#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
GODOT_BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
[[ -x "$GODOT_BIN" ]] || { print -u2 'Set GODOT_BIN to the Godot 4.3 executable.'; exit 1; }
mkdir -p ios dist docs
# When retained locally, use a matching iOS template without editing project paths.
python3 tools/configure_templates.py
"$GODOT_BIN" --headless --path game --export-release iOS ../ios/Bounce.ipa > docs/export.log 2>&1
python3 tools/patch_ios.py
xcodebuild -project ios/Bounce.xcodeproj -scheme Bounce -configuration Release -sdk iphoneos -derivedDataPath build CODE_SIGNING_ALLOWED=NO IPHONEOS_DEPLOYMENT_TARGET=15.0 > docs/xcode-build.log 2>&1
python3 tools/package.py
