#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIDGET="${1:-}"

if [[ -z "$WIDGET" ]]; then
  echo "Usage: $0 <widget-slug>" >&2
  "$ROOT_DIR/scripts/widget_metadata.py" list >&2
  exit 64
fi

"$ROOT_DIR/scripts/build-widget.sh" "$WIDGET"
"$ROOT_DIR/scripts/package-widget.sh" "$WIDGET"

TAG="$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" releaseTag)"
TITLE="$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" releaseTitle)"
NOTES="$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" changelog)"
ARTIFACT="$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" artifact)"
ASSET="$ROOT_DIR/dist/$ARTIFACT.pkarchive"

if gh release view "$TAG" >/dev/null 2>&1; then
  gh release upload "$TAG" "$ASSET" --clobber
else
  gh release create "$TAG" "$ASSET" --title "$TITLE" --notes "$NOTES"
fi

"$ROOT_DIR/scripts/update-catalogs.py"

echo "Released $WIDGET as $TAG"
