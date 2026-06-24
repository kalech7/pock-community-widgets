#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIDGET="${1:-}"

usage() {
  echo "Usage: $0 <better-now-playing|dock>" >&2
}

if [[ -z "$WIDGET" ]]; then
  usage
  exit 64
fi

case "$WIDGET" in
  better-now-playing)
    WIDGET_DIR="$ROOT_DIR/widgets/better-now-playing"
    WORKSPACE="$WIDGET_DIR/Better Now Playing.xcworkspace"
    SCHEME="Better Now Playing"
    ;;
  dock)
    WIDGET_DIR="$ROOT_DIR/widgets/dock"
    WORKSPACE="$WIDGET_DIR/Dock.xcworkspace"
    SCHEME="Dock"
    ;;
  *)
    usage
    exit 64
    ;;
esac

if [[ -f "$WIDGET_DIR/Podfile" ]]; then
  (cd "$WIDGET_DIR" && pod install)
fi

if [[ "$WIDGET" == "better-now-playing" ]]; then
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
