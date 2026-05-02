# widgetation_viewer

Desktop viewer for the [widgetation](../widgetation) package.

Connect to a running app that wraps itself in `InspectorStreamer`, and you
get a live picture of its widget tree:

* Bordered "device frame" showing the streamed PNG.
* Hover anywhere over the image — the smallest widget under the cursor is
  highlighted with a cyan rectangle and labelled.
* Right-side panel: collapsible widget tree (click to pin a selection) and
  a properties view (type, depth, rect, diagnostic properties).
* Window focus drives capture: when this window is unfocused, the streamer
  stops doing work.

## Run

```bash
fvm flutter run -d macos   # or windows / linux
```

Then enter the host/port your app is broadcasting (default `127.0.0.1:7321`)
and click **Connect**.

## Hit-testing

Tree coordinates arrive in logical pixels. The viewer scales the rendered
image to its laid-out size and converts cursor positions back to logical
pixels before walking the tree. The deepest node whose rect contains the
point wins, with a tie-break on smaller area.

## License

MIT.
