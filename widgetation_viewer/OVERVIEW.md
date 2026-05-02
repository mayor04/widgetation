# widgetation_viewer — Viewer Overview

`widgetation_viewer` is the desktop companion app for the
[`widgetation`](../widgetation) package. It connects over WebSocket to a
running Flutter app that wraps itself in `Widgetation`, then renders
a live picture of that app along with a hover-and-click widget inspector.

It is itself a Flutter app (so it runs on macOS, Windows, and Linux — and
the iOS/macOS scaffolding is already in place).

## What it does

- Renders the streamed PNG inside a "device frame" border in the main
  viewport.
- On hover, hit-tests the widget tree at the cursor's *logical* position
  and overlays a cyan rectangle + label on the deepest, smallest widget
  under the pointer.
- Side panel: collapsible widget tree on top, properties view on the
  bottom (type, depth, rect, diagnostic properties, key).
- Click a tree row to **pin** the selection; hovering takes over again
  when the cursor moves over the viewport.
- Lifecycle-aware: when the viewer window loses focus, it tells the
  streamer `focused: false`, which stops the streamer's capture loop —
  so just unfocusing the viewer is enough to make the target app idle.

## Files

```
widgetation_viewer/
├── lib/
│   ├── main.dart                    # MaterialApp + dark theme; mounts InspectorPage
│   └── src/
│       ├── connection.dart          # ConnectionController: WebSocket + listenable state
│       ├── frame.dart               # InspectorFrame, TreeNode, hitTest()
│       ├── inspector_page.dart      # top-level layout: connection bar + viewport + tree panel
│       ├── viewport_view.dart       # PNG display + hover overlay + cursor → logical-px math
│       └── tree_panel.dart          # collapsible tree on top, property list on bottom
├── ios/    macos/                   # platform scaffolding (network.client entitlement on macOS)
└── pubspec.yaml
```

## Top-level structure

`main.dart` mounts `WidgetationViewerApp` → `InspectorPage`. The page
holds:

- a `ConnectionController` (the only stateful piece beyond `_selected`);
- a host/port form in the AppBar with a status dot and Connect /
  Disconnect button;
- a `Row` body: `ViewportView` (flex 3) | divider | `TreePanel` (360 px).

The page subscribes to `WidgetsBindingObserver` so it can translate
window-focus changes into `setFocused(true|false)` on the connection —
see
[inspector_page.dart:30-35](lib/src/inspector_page.dart#L30-L35).

## ConnectionController

`lib/src/connection.dart` owns the WebSocket. Its surface is intentionally
tiny:

- `connect(host, port)` / `disconnect()` / `setFocused(bool)`
- listenable state: `status` (`disconnected | connecting | connected |
  error`), `lastFrame`, `errorMessage`, `serverName`.

On connect it sends `{"type":"hello","fps":8}` and the current
`{"type":"focus", ...}`. Inbound messages are routed by type:

- `hello` → updates `serverName` (shown in the AppBar title).
- `frame` → decodes into `InspectorFrame` and publishes via
  `lastFrame.value`. The whole UI is a `ValueListenableBuilder` over that
  notifier, so each frame triggers exactly one rebuild.

## Frame model & hit-testing

`lib/src/frame.dart` is a plain dart-only mirror of the wire format:

- `InspectorFrame { timestamp, devicePixelRatio, logicalSize, png, tree }`
- `TreeNode { type, depth, x, y, w, h, props, key, children }` —
  coordinates in logical pixels.
- `hitTest(roots, x, y)` walks the tree depth-first and returns the
  deepest node whose rect contains the point, with a tie-break on smaller
  area.

The viewer never runs Flutter's own hit-testing on the streamed image; it
walks the JSON tree the streamer sent.

## Cursor → logical pixels

The PNG arrives sized in **physical** pixels; tree rects are in
**logical** pixels. `ViewportView` lays the PNG out at the available
size and converts a hover offset back to logical coordinates by:

```
logicalX = hover.dx * (frame.logicalSize.w / displayedWidth)
logicalY = hover.dy * (frame.logicalSize.h / displayedHeight)
```

Then it asks `hitTest(frame.tree, logicalX, logicalY)`. Selection is
lifted to `InspectorPage._selected` so the tree panel and the hover
overlay always agree.

## Tree panel

`lib/src/tree_panel.dart` flattens the nested tree into rows lazily based
on a `Set<int> _expanded` of node identities. Click a row to pin
`_selected`; click the chevron to expand/collapse. Below the list a
properties pane shows `{type}`, depth, rect (`x,y w×h`), and the
diagnostic property strings the streamer included.

## Lifecycle ↔ capture

This is the part that keeps the target app cheap:

- `didChangeAppLifecycleState(resumed)` → `setFocused(true)` →
  `{"type":"focus","focused":true}` over the wire → streamer's
  `shouldCapture` flips true → its `Timer.periodic` starts.
- Any other state (`inactive`, `paused`, `hidden`, `detached`) →
  `setFocused(false)` → streamer's timer is cancelled within one round
  trip.

So the rule of thumb is: **viewer in foreground = work, viewer in
background = no work.**

## Running

```bash
fvm flutter run -d macos       # or windows / linux
```

Then enter the host/port the target app is broadcasting (default
`127.0.0.1:7321`) and click **Connect**.

## Platform notes

- macOS: needs the `com.apple.security.network.client` entitlement so
  the sandbox allows outbound WebSocket connections. Already wired into
  `macos/Runner/*.entitlements` (committed in `a588f8a`).
- iOS scaffolding is included for completeness; the viewer's main use
  case is desktop.

## Extending

The whole protocol is in `connection.dart` + `frame.dart`. Adding a new
inbound message type is just another `case` in `_onData`. Adding a new
outbound message is just another `_send({...})`. The viewer doesn't
assume anything about the streamer beyond the JSON format documented in
the package's [OVERVIEW.md](../widgetation/OVERVIEW.md).
