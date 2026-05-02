# Widgetation

Two sibling Flutter projects:

* [`widgetation/`](./widgetation) — pub.dev-ready Flutter package. Wrap
  your app with `InspectorStreamer` and it hosts an on-demand WebSocket
  server that streams the widget tree.
* [`widgetation_viewer/`](./widgetation_viewer) — desktop companion app
  (macOS / Windows / Linux). Connects to a running streamer and renders
  the live screenshot with a hover-to-inspect overlay and a side panel.

## Run them together

In one terminal — start an app that uses the streamer (the package's
example):

```bash
cd widgetation/example
fvm flutter run -d macos      # or any device — iOS, Android, etc.
```

The example wraps itself in `InspectorStreamer` and starts a WebSocket
server on `127.0.0.1:7321`.

In another terminal — start the viewer:

```bash
cd widgetation_viewer
fvm flutter run -d macos
```

In the viewer, leave host/port at the defaults (`127.0.0.1:7321`) and
click **Connect**. As long as the viewer window is focused, frames stream
in at ~8 fps. Hover over the screenshot to highlight the smallest widget
under the cursor; click an entry in the right-hand tree to pin a
selection. Unfocus the viewer window and the streamer goes idle.

## Notes

* Tree coordinates are logical pixels; the PNG is physical pixels. The
  viewer scales image-space to its laid-out size and converts cursor
  positions back to logical pixels before walking the tree.
* In release mode the streamer wrapper is a no-op — no server is bound.
* On macOS, the viewer's entitlements include `network.client`, and the
  example's include `network.server`; both are scaffolded automatically
  by the templates here. iOS / Android need no extra setup for localhost.

## License

Both projects are MIT-licensed. See each project's `LICENSE`.
