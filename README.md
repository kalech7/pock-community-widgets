# Pock Community Widgets

Unofficial community-maintained widget collection for the unofficial
`pock-community` fork. This repository is not the official Pock project and is
not presented as endorsed by the original Pock authors.

The goal is to keep useful Pock widgets buildable, attributable, and packaged
as `.pock` or `.pkarchive` artifacts that `pock-community` can install through a
small JSON catalog.

## Community Repositories

- Pock Community app repository:
  `https://github.com/kalech7/pock-community`
- Pock Community widgets repository:
  `https://github.com/kalech7/pock-community-widgets`

## Widget Locations

The community-maintained widgets live in this repository:

- Better Now Playing Community:
  `widgets/better-now-playing/`
- Dock Community:
  `widgets/dock/`

The catalogs that `pock-community` can use to install or update widgets live in:

- `catalog/defaults.json`
- `catalog/latestVersions.json`

## Included Widgets

| Widget | Slug | Community bundle id | Upstream | Community version |
| --- | --- | --- | --- | --- |
| Better Now Playing Community | `better-now-playing` | `community.pock.widgets.betternowplaying` | `JosephPri/Better-Now-Playing-Pock-Widget` | `1.05.1` |
| Dock Community | `dock` | `community.pock.widgets.dock` | `pock/dock-widget` | `1.4.1` |

## Community Changes

- Uses community bundle identifiers so these builds are not confused with
  official or upstream widget bundles.
- Adds visible community names in widget metadata.
- Points Better Now Playing update checks at this community repository.
- Adds catalog files for future `pock-community` default widget installation.
- Preserves upstream copyright notices, licenses where present, and attribution.

## Build

Requirements:

- macOS with full Xcode selected via `xcode-select`
- CocoaPods for widgets that still use `Podfile`
- CMake for Better Now Playing's `mediaremote-adapter`

Build one widget:

```sh
./scripts/build-widget.sh better-now-playing
./scripts/build-widget.sh dock
```

Package a built `.pock` bundle:

```sh
./scripts/package-widget.sh better-now-playing
./scripts/package-widget.sh dock
```

The package script writes `.pkarchive` files into `dist/`.

## Widget Metadata

Each widget has a `widget.json` file that is the source of truth for build,
release, and catalog metadata:

```json
{
  "slug": "example-widget",
  "name": "Example Widget Community",
  "bundleIdentifier": "community.pock.widgets.examplewidget",
  "version": "1.0.0",
  "artifact": "ExampleWidgetCommunity",
  "releaseTag": "example-widget-community-1.0.0",
  "releaseTitle": "Example Widget Community 1.0.0",
  "changelog": "Initial community release.",
  "coreMin": "0.10.0-5",
  "enabledByDefault": false,
  "workspace": "Example Widget.xcworkspace",
  "scheme": "Example Widget",
  "pockName": "Example Widget.pock",
  "requiresMediaRemoteAdapter": false,
  "licenseStatus": "MIT"
}
```

Useful metadata commands:

```sh
./scripts/widget_metadata.py list
./scripts/widget_metadata.py json better-now-playing
./scripts/widget_metadata.py asset-url dock
```

## Creating A Widget

Create a scaffold:

```sh
./scripts/new-widget.sh example-widget "Example Widget Community"
```

The scaffold creates `widget.json`, `Podfile`, `Info.plist`, a starter Swift
file, and community documentation. Then create the matching macOS bundle target
in Xcode as described in the generated widget README.

## Catalog Generation

Catalog files are generated from all `widgets/*/widget.json` files:

```sh
./scripts/update-catalogs.py
./scripts/check-catalog-json.sh
```

Do not edit catalog URLs by hand unless you also update the matching
`widget.json`.

## Catalogs

- `catalog/defaults.json` maps widget bundle identifiers to downloadable
  `.pkarchive` URLs.
- `catalog/latestVersions.json` follows the structure expected by
  `pock-community`'s current `Updater` model.

Release URLs currently target the expected future GitHub repository:
`https://github.com/kalech7/pock-community-widgets`.

## Release Process

The release process is documented in `MAINTAINING.md`. In short:

1. Change the widget version.
2. Update the widget's `widget.json`.
3. Run `./scripts/update-catalogs.py`.
4. Commit and push the changes.
5. Run the `Build widget releases` GitHub Actions workflow.
6. Verify that the GitHub release asset exists and that GitHub Pages serves the
   updated catalog JSON.

## License And Attribution

This repository is a collection of upstream snapshots plus community metadata.
Community-authored repository scaffolding is MIT licensed. Each imported widget
keeps its original attribution and license status. See `AUTHORS.md`,
`NOTICE.md`, and each widget folder before publishing release artifacts. Dock
Community must be distributed under MIT terms; new Dock artifacts require
confirmed MIT licensing or MIT-compatible upstream permission.
