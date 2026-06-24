#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m json.tool "$ROOT_DIR/catalog/defaults.json" >/dev/null
python3 -m json.tool "$ROOT_DIR/catalog/latestVersions.json" >/dev/null
python3 -m json.tool "$ROOT_DIR/widgets/better-now-playing/appcast.json" >/dev/null

echo "Catalog JSON is valid."

