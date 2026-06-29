#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLUG="${1:-}"
NAME="${2:-}"

if [[ -z "$SLUG" || -z "$NAME" ]]; then
  echo "Usage: $0 <widget-slug> \"Widget Display Name\"" >&2
  exit 64
fi

WIDGET_DIR="$ROOT_DIR/widgets/$SLUG"
if [[ -e "$WIDGET_DIR" ]]; then
  echo "Widget already exists: $WIDGET_DIR" >&2
  exit 73
fi

CLASS_NAME="$(python3 - "$NAME" <<'PY'
import re, sys
name = sys.argv[1]
parts = re.findall(r"[A-Za-z0-9]+", name)
print("".join(part[:1].upper() + part[1:] for part in parts) or "Widget")
PY
)"
BUNDLE_SUFFIX="$(python3 - "$SLUG" <<'PY'
import re, sys
print(re.sub(r"[^a-z0-9]+", "", sys.argv[1].lower()))
PY
)"
ARTIFACT="${CLASS_NAME}Community"
RELEASE_TAG="${SLUG}-community-1.0.0"

mkdir -p "$WIDGET_DIR/Sources"

cat > "$WIDGET_DIR/widget.json" <<JSON
{
  "slug": "$SLUG",
  "name": "$NAME",
  "bundleIdentifier": "community.pock.widgets.$BUNDLE_SUFFIX",
  "version": "1.0.0",
  "artifact": "$ARTIFACT",
  "releaseTag": "$RELEASE_TAG",
  "releaseTitle": "$NAME 1.0.0",
  "changelog": "Initial community release.",
  "coreMin": "0.10.0-5",
  "enabledByDefault": false,
  "workspace": "$NAME.xcworkspace",
  "scheme": "$NAME",
  "pockName": "$NAME.pock",
  "requiresMediaRemoteAdapter": false,
  "licenseStatus": "MIT"
}
JSON

cat > "$WIDGET_DIR/Podfile" <<RUBY
platform :osx, '10.15'

target '$NAME' do
  use_frameworks!
  pod 'PockKit', '0.3.0'
  pod 'TinyConstraints'
end
RUBY

cat > "$WIDGET_DIR/Sources/$CLASS_NAME.swift" <<SWIFT
import AppKit
import PockKit

final class $CLASS_NAME: NSObject, PKWidget {
    static var identifier: String = "$CLASS_NAME"

    var customizationLabel: String = "$NAME"
    var view: NSView!

    required override init() {
        super.init()
        let label = NSTextField(labelWithString: "$NAME")
        label.alignment = .center
        label.textColor = .labelColor
        label.font = .systemFont(ofSize: 13, weight: .medium)
        self.view = label
    }
}
SWIFT

cat > "$WIDGET_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrincipalClass</key>
	<string>$CLASS_NAME.$CLASS_NAME</string>
	<key>PKWidgetAuthor</key>
	<string>Pock Community</string>
	<key>PKWidgetName</key>
	<string>$NAME</string>
</dict>
</plist>
PLIST

cat > "$WIDGET_DIR/README.md" <<MD
# $NAME

Community widget scaffold.

Next steps:

1. Create a macOS bundle target in Xcode named \`$NAME\`.
2. Set the product wrapper extension to \`.pock\`.
3. Use \`Info.plist\` from this folder as the target Info.plist.
4. Add \`Sources/$CLASS_NAME.swift\` to the target.
5. Run \`pod install\`.
6. Build with:

\`\`\`sh
../../scripts/build-widget.sh $SLUG
\`\`\`
MD

cat > "$WIDGET_DIR/COMMUNITY.md" <<MD
# $NAME

This widget was scaffolded for Pock Community.

- Bundle identifier: \`community.pock.widgets.$BUNDLE_SUFFIX\`
- Version: \`1.0.0\`
- License status: MIT
MD

echo "Created $WIDGET_DIR"
echo "Open Xcode and create the bundle target described in $WIDGET_DIR/README.md."
