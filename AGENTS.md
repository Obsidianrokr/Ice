# Ice — agent notes

## Versioning

This fork uses its own semver in `Ice.xcodeproj`:

- `MARKETING_VERSION` — user-facing version (e.g. `1.0.1`); **bump the patch** for each release (`1.0.2`, `1.0.3`, …)
- `CURRENT_PROJECT_VERSION` — build number; increment with each install build

Sparkle auto-update is **disabled** (`Version.updatesEnabled = false`). Do not restore upstream `SUFeedURL` in `Ice/Resources/Info.plist`.


**Always install to `/Applications/Ice.app` only.** Do not install or launch Ice from DerivedData or other paths.

```bash
pkill -x Ice 2>/dev/null
ditto .derivedData/Build/Products/Release/Ice.app /Applications/Ice.app
open /Applications/Ice.app
```

Build first with Release + ad-hoc signing (`CODE_SIGN_IDENTITY="-" CODE_SIGNING_ALLOWED=NO`).

## Why only one install

A second copy (e.g. Xcode Debug at `~/Library/Developer/Xcode/DerivedData/.../Ice.app`) is a separate signed binary. macOS treats it as a different app for Accessibility, Input Monitoring, and Screen Recording — causing duplicate `Ice.app` entries and broken permissions.

When installing or debugging permissions, use **`/Applications/Ice.app`** exclusively.
