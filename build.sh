#!/bin/zsh
set -euo pipefail
cd "${0:A:h}"
mkdir -p ios dist docs
./tools/godot43/Godot.app/Contents/MacOS/Godot --headless --path game --export-release iOS ../ios/Bounce.ipa > docs/export.log 2>&1
python3 tools/patch_ios.py
xcodebuild -project ios/Bounce.xcodeproj -scheme Bounce -configuration Release -sdk iphoneos -derivedDataPath build CODE_SIGNING_ALLOWED=NO IPHONEOS_DEPLOYMENT_TARGET=15.0 > docs/xcode-build.log 2>&1
python3 tools/package.py
