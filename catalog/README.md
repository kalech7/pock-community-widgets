# Widget Catalogs

`pock-community` currently expects two network payload shapes:

- Default widgets: a JSON object of `bundleIdentifier` to downloadable URL.
- Latest versions: a JSON object with `core` and `widgets` version records.

This directory stores those payloads as static JSON so they can be hosted from
GitHub Pages, raw GitHub, or another simple static host.

Do not point a public app build at these files until release assets exist for
every URL listed in `defaults.json` and `latestVersions.json`.

