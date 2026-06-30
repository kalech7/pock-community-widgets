#!/usr/bin/env python3
import json
import pathlib
import sys

import widget_metadata


ROOT = pathlib.Path(__file__).resolve().parents[1]
CATALOG_DIR = ROOT / "catalog"
CORE_VERSION = "0.10.1-8"


def main():
    check_only = "--check" in sys.argv
    defaults = {}
    latest_versions = {
        "core": {
            "name": CORE_VERSION,
            "link": "https://github.com/kalech7/pock-community/releases",
            "changelog": "Community-maintained Pock build.",
            "core_min": None,
        },
        "widgets": {},
    }

    for widget in widget_metadata.iter_widgets():
        url = widget_metadata.asset_url(widget)
        if widget.get("enabledByDefault", False):
            defaults[widget["bundleIdentifier"]] = url
        latest_versions["widgets"][widget["bundleIdentifier"]] = {
            "name": widget["version"],
            "link": url,
            "changelog": widget["changelog"],
            "core_min": widget["coreMin"],
        }

    generated = {
        "defaults.json": json.dumps(defaults, indent=2, sort_keys=True) + "\n",
        "latestVersions.json": json.dumps(latest_versions, indent=2, sort_keys=True) + "\n",
    }

    if check_only:
        stale = []
        for filename, contents in generated.items():
            path = CATALOG_DIR / filename
            if not path.exists() or path.read_text(encoding="utf-8") != contents:
                stale.append(filename)
        if stale:
            print(f"Catalog JSON is stale: {', '.join(stale)}", file=sys.stderr)
            print("Run ./scripts/update-catalogs.py", file=sys.stderr)
            sys.exit(1)
        print("Catalog JSON matches widget metadata.")
        return

    CATALOG_DIR.mkdir(exist_ok=True)
    for filename, contents in generated.items():
        (CATALOG_DIR / filename).write_text(contents, encoding="utf-8")

    print("Catalog JSON updated.")


if __name__ == "__main__":
    main()
