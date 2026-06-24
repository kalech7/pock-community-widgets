# Pock Community Widgets

Unofficial community-maintained widget collection for the unofficial
`pock-community` fork. This repository is not the official Pock project and is
not presented as endorsed by the original Pock authors.

The goal is to keep useful Pock widgets buildable, attributable, and packaged
as `.pock` or `.pkarchive` artifacts that `pock-community` can install through a
small JSON catalog.

## Repositorios Community

- Pock Community app:
  `https://github.com/kalech7/pock-community`
- Community widgets:
  `https://github.com/kalech7/pock-community-widgets`

## Donde Estan Los Widgets

Los widgets mantenidos por la comunidad viven en este repo:

- Better Now Playing Community:
  `widgets/better-now-playing/`
- Dock Community:
  `widgets/dock/`

Los catalogos que `pock-community` puede usar para instalar o actualizar
widgets estan en:

- `catalog/defaults.json`
- `catalog/latestVersions.json`

## Included Widgets

| Widget | Community bundle id | Upstream | Community version |
| --- | --- | --- | --- |
| Better Now Playing Community | `community.pock.widgets.betternowplaying` | `JosephPri/Better-Now-Playing-Pock-Widget` | `1.05.1` |
| Dock Community | `community.pock.widgets.dock` | `pock/dock-widget` | `1.4.1` |

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
./scripts/package-widget.sh "/path/to/Better Now Playing.pock" BetterNowPlayingCommunity
./scripts/package-widget.sh "/path/to/Dock.pock" DockCommunity
```

The package script writes `.pkarchive` files into `dist/`.

## Catalogs

- `catalog/defaults.json` maps widget bundle identifiers to downloadable
  `.pkarchive` URLs.
- `catalog/latestVersions.json` follows the structure expected by
  `pock-community`'s current `Updater` model.

Release URLs currently target the expected future GitHub repository:
`https://github.com/kalech7/pock-community-widgets`.

## License And Attribution

This repository is a collection of upstream snapshots plus community metadata.
Community-authored repository scaffolding is MIT licensed. Each imported widget
keeps its original attribution and license status. See `AUTHORS.md`,
`NOTICE.md`, and each widget folder before publishing release artifacts. Dock
release artifacts remain pending upstream license confirmation.
