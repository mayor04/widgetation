# widgetation

On-demand widget tree streamer for Flutter. Wrap your app once, then connect
the companion **widgetation_viewer** desktop app to inspect your running app
in real time — screenshot + per-widget metadata, only while the viewer is
focused.

## Why

Flutter DevTools is great, but it's a heavy attach-and-introspect tool. This
package is much smaller in scope: a live picture-of-your-app + a hover-to-
inspect overlay, streamed over the local network. Capture only runs while a
viewer is connected and focused, so day-to-day overhead is essentially zero.

## Install

```yaml
dependencies:
  widgetation: ^0.1.0
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  runApp(const InspectorStreamer(child: MyApp()));
}
```

That's the whole integration surface. Optional configuration:

```dart
InspectorStreamer(
  config: const WidgetationConfig(
    port: 7321,
    name: 'MyApp on iPhone 15',
    fps: 8,
  ),
  child: MyApp(),
)
```

In release mode the wrapper is a no-op. The server only binds in debug /
profile builds.

## How it works

* Wraps `child` in a `RepaintBoundary` keyed by a `GlobalKey`.
* Hosts a tiny WebSocket server (`ws://127.0.0.1:7321` by default).
* When the viewer connects and signals `focused: true`, a `Timer.periodic`
  starts capturing at the configured fps.
* Each frame: `RenderRepaintBoundary.toImage()` then PNG then base64, plus
  a walk of the element tree producing `{type, depth, x, y, w, h, props}`
  per widget.
* When the viewer disconnects or signals `focused: false`, the timer stops.

## Protocol

JSON messages over a single WebSocket.

* client to server: `{"type":"hello","fps":8}`, `{"type":"focus","focused":true}`
* server to client: `{"type":"hello","name":"...","version":1}`
* server to client per frame:

  ```json
  {
    "type": "frame",
    "timestamp": 1714377600000,
    "devicePixelRatio": 2.0,
    "screenSize": {"w": 390, "h": 844},
    "screenshot": "<base64 PNG>",
    "tree": [{"type":"MaterialApp","depth":0,"x":0,"y":0,"w":390,"h":844,"props":[],"children":[]}]
  }
  ```

## License

MIT.
