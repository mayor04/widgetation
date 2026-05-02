# widgetation_viewer

Desktop viewer for the [widgetation](../widgetation) package.

> Work in progress — UI lands in subsequent commits.

## Platform scaffolding

This directory commits only the cross-platform Dart sources
(`lib/`, `test/`, `pubspec.yaml`, `analysis_options.yaml`,
`.metadata`). The per-platform runners (`macos/`, `linux/`,
`windows/`) are generated locally with:

```bash
fvm flutter create --platforms macos,linux,windows .
```
