# example

Demo app for the [`widgetation`](../) package. Wraps a small Material UI
in `InspectorStreamer` and listens for the desktop viewer.

## Run

```bash
fvm flutter pub get
fvm flutter run -d macos    # or any device — ios / android / etc.
```

## Platform scaffolding

This directory commits only the cross-platform Dart sources
(`lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml`). The
per-platform runners (`ios/`, `android/`, `macos/`, …) are generated
locally with:

```bash
fvm flutter create --platforms macos,ios,android .
```

That command is idempotent — re-run it whenever you want a new
platform target.
