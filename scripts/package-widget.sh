#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIDGET_OR_PATH="${1:-}"
ARTIFACT_NAME="${2:-}"
OUT_DIR="${3:-$ROOT_DIR/dist}"

if [[ -z "$WIDGET_OR_PATH" ]]; then
  echo "Usage: $0 <widget-slug|/path/to/Widget.pock> [ArtifactName] [output-directory]" >&2
  exit 64
fi

if [[ -d "$ROOT_DIR/widgets/$WIDGET_OR_PATH" ]]; then
  WIDGET="$WIDGET_OR_PATH"
  POCK_PATH="$(find "$ROOT_DIR/.build/Products/$WIDGET" -name '*.pock' -print -quit)"
  ARTIFACT_NAME="$("$ROOT_DIR/scripts/widget_metadata.py" field "$WIDGET" artifact)"
else
  POCK_PATH="$WIDGET_OR_PATH"
fi

if [[ -z "$ARTIFACT_NAME" ]]; then
  echo "Artifact name is required when packaging by path." >&2
  exit 64
fi

if [[ ! -d "$POCK_PATH" ]]; then
  echo "Widget bundle not found: $POCK_PATH" >&2
  exit 66
fi

mkdir -p "$OUT_DIR"
ARCHIVE_PATH="$OUT_DIR/$ARTIFACT_NAME.pkarchive"
rm -f "$ARCHIVE_PATH"

ditto -c -k --sequesterRsrc --keepParent "$POCK_PATH" "$ARCHIVE_PATH"

echo "$ARCHIVE_PATH"
