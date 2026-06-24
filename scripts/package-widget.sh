#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POCK_PATH="${1:-}"
ARTIFACT_NAME="${2:-}"
OUT_DIR="${3:-$ROOT_DIR/dist}"

if [[ -z "$POCK_PATH" || -z "$ARTIFACT_NAME" ]]; then
  echo "Usage: $0 /path/to/Widget.pock ArtifactName [output-directory]" >&2
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

