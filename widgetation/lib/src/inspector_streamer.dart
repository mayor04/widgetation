import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'streaming_server.dart';

/// Wrap your app's root with [InspectorStreamer] to expose a local WebSocket
/// server that streams screenshots + widget tree metadata on demand.
///
/// ```dart
/// void main() {
///   runApp(const InspectorStreamer(child: MyApp()));
/// }
/// ```
///
/// Capture is gated: it only runs while a viewer is connected and reports
/// itself focused. There is no continuous overhead during normal use.
class InspectorStreamer extends StatefulWidget {
  /// Your application's root widget.
  final Widget child;

  /// Optional configuration. See [WidgetationConfig].
  final WidgetationConfig config;

  const InspectorStreamer({
    super.key,
    required this.child,
    this.config = const WidgetationConfig(),
  });

  @override
  State<InspectorStreamer> createState() => _InspectorStreamerState();
}

class _InspectorStreamerState extends State<InspectorStreamer> {
  final GlobalKey _captureKey = GlobalKey(debugLabel: 'widgetation.capture');
  StreamingServer? _server;

  @override
  void initState() {
    super.initState();
    if (widget.config.enabled && !kReleaseMode) {
      _bootServer();
    }
  }

  Future<void> _bootServer() async {
    final cfg = widget.config;
    final server = StreamingServer(host: cfg.host, port: cfg.port, name: cfg.name);
    try {
      await server.start();
    } catch (e) {
      debugPrint('[widgetation] failed to bind ${cfg.host}:${cfg.port}: $e');
      return;
    }
    _server = server;
  }

  @override
  void dispose() {
    _server?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.enabled || kReleaseMode) {
      return widget.child;
    }
    return RepaintBoundary(key: _captureKey, child: widget.child);
  }
}
