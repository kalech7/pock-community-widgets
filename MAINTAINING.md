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
5. Run:

```sh
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
2. Build `.pock` bundles from a clean checkout.
3. Package `.pkarchive` files with `scripts/package-widget.sh`.
4. Create GitHub release assets matching `catalog/defaults.json` and
   `catalog/latestVersions.json`.
5. Verify that `pock-community` can download and install each `.pkarchive`.

Do not publish Dock release artifacts until the upstream license status is
confirmed or permission is obtained.

