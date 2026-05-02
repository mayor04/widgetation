import 'package:flutter/widgets.dart';

/// What [Widgetation] does at runtime.
enum WidgetationMode {
  /// No-op. Same effect as `enabled: false`.
  none,

  /// Stream PNG + tree to the desktop viewer when it connects + focuses.
  image,

  /// No streaming. Render a floating button; tapping it enters an on-device
  /// select overlay that highlights the widget under the pointer.
  edit,
}

/// Configuration for [Widgetation].
class WidgetationConfig {
  final WidgetationMode mode;

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

  /// Where the floating select-mode button sits in [WidgetationMode.edit].
  final AlignmentGeometry selectButtonAlignment;

  /// Kill switch. When false, the streamer no-ops regardless of [mode].
  final bool enabled;

  const WidgetationConfig({
    this.mode = WidgetationMode.edit,
    this.port = 7321,
    this.host = '127.0.0.1',
    this.name = 'Flutter App',
    this.fps = 8,
    this.pixelRatio,
    this.selectButtonAlignment = Alignment.bottomRight,
    this.enabled = true,
  });

  int get clampedFps => fps.clamp(1, 30);

  bool get isActive => enabled && mode != WidgetationMode.none;
}
