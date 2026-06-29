#!/usr/bin/env python3
import json
import pathlib
import sys


ROOT = pathlib.Path(__file__).resolve().parents[1]
WIDGETS_DIR = ROOT / "widgets"


def widget_path(slug):
    return WIDGETS_DIR / slug


def metadata_path(slug):
    return widget_path(slug) / "widget.json"


def load_widget(slug):
    path = metadata_path(slug)
    if not path.exists():
        raise SystemExit(f"Missing widget metadata: {path}")
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    data.setdefault("slug", slug)
    required = [
        "slug",
        "name",
        "bundleIdentifier",
        "version",
        "artifact",
        "releaseTag",
        "releaseTitle",
        "changelog",
        "coreMin",
        "workspace",
        "scheme",
        "pockName",
    ]
    missing = [key for key in required if key not in data]
    if missing:
        raise SystemExit(f"{path} is missing required keys: {', '.join(missing)}")
    return data


def iter_widgets():
    for path in sorted(WIDGETS_DIR.glob("*/widget.json")):
        yield load_widget(path.parent.name)


def asset_url(widget):
    return (
        "https://github.com/kalech7/pock-community-widgets/releases/download/"
        f"{widget['releaseTag']}/{widget['artifact']}.pkarchive"
    )


def main():
    if len(sys.argv) < 2:
        raise SystemExit("Usage: widget_metadata.py <list|field|json|asset-url> [slug] [field]")

    command = sys.argv[1]
    if command == "list":
        print("\n".join(widget["slug"] for widget in iter_widgets()))
        return

    if len(sys.argv) < 3:
        raise SystemExit(f"Usage: widget_metadata.py {command} <slug>")

    slug = sys.argv[2]
    widget = load_widget(slug)

    if command == "json":
        print(json.dumps(widget, indent=2, sort_keys=True))
    elif command == "asset-url":
        print(asset_url(widget))
    elif command == "field":
        if len(sys.argv) != 4:
            raise SystemExit("Usage: widget_metadata.py field <slug> <field>")
        value = widget[sys.argv[3]]
        if isinstance(value, bool):
            print("true" if value else "false")
        else:
            print(value)
    else:
        raise SystemExit(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
