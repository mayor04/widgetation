/// Configuration for [InspectorStreamer].
class WidgetationConfig {
  /// TCP port the WebSocket server binds to. Defaults to 7321.
  final int port;

  /// Host interface to bind. Defaults to `127.0.0.1` (localhost only).
  /// Use `0.0.0.0` to expose on the LAN.
  final String host;

  /// Friendly name reported to the viewer (e.g. "MyApp on iPhone 15").
  final String name;

  /// Maximum capture rate while a viewer is focused. Capped to [1, 30].
  final int fps;

  /// Pixel ratio used when rasterising. Lower values = smaller payloads.
  /// `null` = use the device's native ratio.
  final double? pixelRatio;

  /// Whether the streamer is enabled at all. Set to `false` to no-op (e.g.
  /// in release builds).
  final bool enabled;

  const WidgetationConfig({
    this.port = 7321,
    this.host = '127.0.0.1',
    this.name = 'Flutter App',
    this.fps = 8,
    this.pixelRatio,
    this.enabled = true,
  });

  int get clampedFps => fps.clamp(1, 30);
}
