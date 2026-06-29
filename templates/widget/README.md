# Widget Template

Use `../../scripts/new-widget.sh <slug> "Widget Name Community"` from the
repository root to create a new widget scaffold.

The generated scaffold includes:

- `widget.json` for build, release, and catalog metadata
- `Podfile` pinned to community-supported dependencies
- `Info.plist` with Pock widget metadata
- starter Swift source
- local `README.md` and `COMMUNITY.md`

After scaffolding, create the matching macOS bundle target in Xcode, run
`pod install`, then build through `scripts/build-widget.sh`.
