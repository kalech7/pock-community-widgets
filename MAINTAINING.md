# Maintaining Widget Snapshots

Use small, reviewable updates. Keep upstream attribution and copyright notices
intact.

## Refresh A Widget From Upstream

1. Clone the upstream repository into a temporary directory.
2. Record the upstream commit hash in `AUTHORS.md` and the widget's
   `COMMUNITY.md`.
3. Copy the upstream working tree into the matching `widgets/<name>/` folder.
   For Better Now Playing, clone with `--recursive` so `mediaremote-adapter`
   source and its license are present.
4. Reapply community metadata:
   - community bundle identifier
   - community display name
   - community widget author field
   - community update URLs
   - community version bump
   - `widget.json`
5. Run:

```sh
./scripts/update-catalogs.py
./scripts/check-catalog-json.sh
plutil -lint widgets/better-now-playing/Better\ Now\ Playing/Info.plist widgets/dock/Dock/Info.plist
```

6. Build with full Xcode selected:

```sh
./scripts/build-widget.sh better-now-playing
./scripts/build-widget.sh dock
```

## Release Checklist

1. Confirm license status for every widget being published.
2. Change the widget version in the Xcode project build settings.
3. Update the widget's `widget.json` with the new `version`, `releaseTag`,
   `releaseTitle`, and `changelog`.
4. Regenerate catalogs:

```sh
./scripts/update-catalogs.py
```

5. Commit and push the source, metadata, and catalog changes.
6. Run the GitHub Actions workflow named `Build widget releases` from the
   repository Actions tab, or from the command line:

```sh
gh workflow run build-widget-releases.yml --repo kalech7/pock-community-widgets --ref main
```

7. Wait for the workflow to finish successfully.
8. Verify that the expected GitHub release exists and contains the expected
   `.pkarchive` asset:

```sh
gh release view better-now-playing-community-1.05.1 --repo kalech7/pock-community-widgets --json tagName,url,assets
gh release view dock-community-1.4.1 --repo kalech7/pock-community-widgets --json tagName,url,assets
```

9. Verify the release asset URL from the catalogs resolves:

```sh
curl -fsI https://github.com/kalech7/pock-community-widgets/releases/download/better-now-playing-community-1.05.1/BetterNowPlayingCommunity.pkarchive
curl -fsI https://github.com/kalech7/pock-community-widgets/releases/download/dock-community-1.4.1/DockCommunity.pkarchive
```

10. Verify that GitHub Pages is serving valid catalog JSON:

```sh
curl -fsSL https://kalech7.github.io/pock-community-widgets/catalog/defaults.json | python3 -m json.tool
curl -fsSL https://kalech7.github.io/pock-community-widgets/catalog/latestVersions.json | python3 -m json.tool
```

11. Verify that `pock-community` can download and install each `.pkarchive`.

Dock Community policy: Dock release artifacts must be covered by an MIT license
before being distributed as a community widget. Do not publish new Dock release
artifacts unless the upstream Dock widget license is confirmed as MIT or the
upstream rights holder grants MIT-compatible permission.

## Version Bump Example

For a Better Now Playing update from `1.05.1` to `1.05.2`:

1. Change the widget's `MARKETING_VERSION` to `1.05.2`.
2. Update `widgets/better-now-playing/widget.json`:

```json
"version": "1.05.2",
"releaseTag": "better-now-playing-community-1.05.2",
"releaseTitle": "Better Now Playing Community 1.05.2",
"changelog": "Describe the user-visible changes here."
```

3. Regenerate catalogs:

```sh
./scripts/update-catalogs.py
```

4. Push the change and run `Build widget releases`.

## Local One-Widget Release

When you have full Xcode locally, you can build, package, publish, and
regenerate catalogs for one widget with:

```sh
./scripts/release-widget.sh better-now-playing
```

For CI-driven releases, prefer the GitHub Actions workflow so artifacts are
built in a consistent macOS runner.
