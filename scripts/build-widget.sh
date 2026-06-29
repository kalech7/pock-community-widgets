#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIDGET="${1:-}"

usage() {
  echo "Usage: $0 <widget-slug>" >&2
  echo "Available widgets:" >&2
  "$ROOT_DIR/scripts/widget_metadata.py" list >&2
}

if [[ -z "$WIDGET" ]]; then
  usage
  exit 64
fi

WIDGET_DIR="$ROOT_DIR/widgets/$WIDGET"
WORKSPACE="$WIDGET_DIR/$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" workspace)"
SCHEME="$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" scheme)"
REQUIRES_MEDIA_REMOTE="$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" requiresMediaRemoteAdapter 2>/dev/null || echo false)"

if [[ -f "$WIDGET_DIR/Podfile" ]]; then
  (cd "$WIDGET_DIR" && pod install)
fi

if [[ "$REQUIRES_MEDIA_REMOTE" == "true" ]]; then
  if [[ -d "$WIDGET_DIR/mediaremote-adapter" ]]; then
    cmake -S "$WIDGET_DIR/mediaremote-adapter" -B "$WIDGET_DIR/mediaremote-adapter/build"
    cmake --build "$WIDGET_DIR/mediaremote-adapter/build"
  fi
fi

xcodebuild \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$ROOT_DIR/.build/DerivedData/$WIDGET" \
  SYMROOT="$ROOT_DIR/.build/Products/$WIDGET" \
  CODE_SIGNING_ALLOWED=NO \
  build

echo "Built products:"
find "$ROOT_DIR/.build/Products/$WIDGET" -maxdepth 4 -name '*.pock' -print
