# widgetation — Package Overview

`widgetation` is a small Flutter package that turns any Flutter app into a
live, inspectable target for the companion `widgetation_viewer` desktop app.
You wrap your app's root once; the package then hosts an on-demand
WebSocket server that streams a screenshot plus widget-tree metadata while a
viewer is connected and focused. When nothing is connected (or the viewer's
window is in the background), the package does no work.

## Goals

- **Single-line integration.** `runApp(Widgetation(child: MyApp()))`
  is the entire setup. No platform plugins, no native code, no DevTools
  attach dance.
- **Zero overhead at rest.** Capture only runs while the viewer is
  connected *and* signals it's focused. In release builds the wrapper is a
  no-op and never binds a port.
- **Tiny wire format.** Pure JSON over a single WebSocket. Each frame is a
  base64 PNG plus a flat-ish list of nodes with `{type, depth, x, y, w, h,
  props}`. Anyone can write another viewer in any language.

## Files

```
widgetation/
├── lib/
│   ├── widgetation.dart            # public exports: Widgetation, WidgetationConfig
│   └── src/
│       ├── config.dart             # WidgetationConfig: port, host, name, fps, pixelRatio, enabled
│       ├── widgetation.dart # the StatefulWidget wrapper + capture loop
│       ├── streaming_server.dart   # one-viewer-at-a-time WebSocket server
│       └── tree_walker.dart        # element-tree → JSON nodes (rect + diagnostics)
├── example/                        # runnable Flutter app that wraps itself in Widgetation
├── test/
└── pubspec.yaml                    # name: widgetation, version: 0.1.0
```

## How it fits together

`Widgetation` is the only public widget. Behind the scenes:

1. **Mount.** In debug/profile mode (and only when `config.enabled`), the
   widget builds a `RepaintBoundary` keyed by a `GlobalKey` around `child`
   and boots a `StreamingServer` on `host:port` (default
   `127.0.0.1:7321`). In release mode `build` returns `child` unchanged
   and no server is started — see
   [widgetation.dart:48-54](lib/src/widgetation.dart#L48-L54).
2. **Idle.** The server listens, but until a viewer connects and tells us
   it's focused (`{"type":"focus","focused":true}`), `shouldCapture` stays
   false and no timer runs. A `ValueNotifier<bool> shouldCapture` is the
   single source of truth — the streamer just listens to it.
3. **Capture.** When `shouldCapture` flips true,
   `_startCapture` schedules a `Timer.periodic` at the requested fps
   (clamped to `[1, 30]`). Each tick:
   - Wait for `SchedulerBinding.instance.endOfFrame` so we don't grab a
     half-built frame.
   - `RenderRepaintBoundary.toImage(pixelRatio: dpr)` → `toByteData(png)`
     → base64.
   - `walkTree(element)` produces a JSON-friendly tree of `{type, depth,
     x, y, w, h, props, key, children}` per node, where rects come from
     `RenderBox.localToGlobal(Offset.zero)` and `size`. Non-RenderBox or
     unattached subtrees still emit nodes but with a zero-area rect so the
     viewer's hit-testing skips them.
   - Send one `{"type":"frame", ...}` JSON message.
4. **Backpressure.** A `_capturing` re-entrancy guard prevents stacking
   captures if a tick takes longer than its period.
5. **Tear-down.** Disconnect or focus=false → cancel the timer. `dispose`
   closes the socket and the HTTP server.

## Wire protocol

Single WebSocket, JSON only. Documented at
[lib/src/streaming_server.dart:9-16](lib/src/streaming_server.dart#L9-L16).

```
client → server   {"type":"hello", "fps": 8}
client → server   {"type":"focus", "focused": true|false}

server → client   {"type":"hello", "name":"<server name>", "version": 1}
server → client   {"type":"frame",
                   "timestamp": <ms epoch>,
                   "devicePixelRatio": <double>,
                   "screenSize": {"w": <logical px>, "h": <logical px>},
                   "screenshot": "<base64 PNG, in physical px>",
                   "tree": [ {"type": "...", "depth": 0,
                              "x":..., "y":..., "w":..., "h":...,
                              "props":[...], "children":[...]} ]}
```

A non-WebSocket GET to the same port returns a tiny JSON health blob
`{"name":..., "protocol":"widgetation/1"}` so you can `curl` it to confirm
the server is alive.

Only one viewer is allowed at a time — a second connecting socket evicts
the previous one with `policyViolation`.

## Configuration

`WidgetationConfig` (all fields optional):

| field        | default       | meaning                                                   |
| ------------ | ------------- | --------------------------------------------------------- |
| `port`       | `7321`        | TCP port to bind                                          |
| `host`       | `127.0.0.1`   | bind interface (`0.0.0.0` to expose on LAN)               |
| `name`       | `Flutter App` | friendly label sent in the server `hello`                 |
| `fps`        | `8`           | max capture rate; clamped `[1, 30]`                       |
| `pixelRatio` | `null`        | rasterisation pixel ratio; `null` = use `View.devicePixelRatio` |
| `enabled`    | `true`        | hard kill switch; combined with `kReleaseMode`            |

## Coordinate system

- **Tree rects** are emitted in **logical pixels** (Flutter's
  `localToGlobal` + `size`).
- **Screenshot PNG** is in **physical pixels** (`devicePixelRatio` from
  `View`).

The viewer is responsible for scaling cursor positions back into logical
pixels before walking the tree — see the viewer's overview for details.

## Platform notes

- **macOS app embedding the package** needs the
  `com.apple.security.network.server` entitlement so the sandbox lets the
  WebSocket server bind. The example's `macos/Runner/*.entitlements`
  files include it.
- iOS / Android need no extra setup for localhost loopback.
- Linux / Windows: works out of the box.

## Limits / known gaps

- Single connected viewer at a time (intentional — newer connection
  evicts the older).
- Property summaries are best-effort `toDescription()` strings, capped to
  16 per node.
- No authentication. Bind to `127.0.0.1` (default) unless you trust your
  network.
