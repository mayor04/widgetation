import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'streaming_server.dart';
import 'tree_walker.dart';

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
  Timer? _captureTimer;
  bool _capturing = false;

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
    _startCapture();
  }

  void _startCapture() {
    final cfg = widget.config;
    _captureTimer?.cancel();
    final fps = (_server?.requestedFps ?? cfg.clampedFps).clamp(1, 30);
    final period = Duration(milliseconds: (1000 / fps).round());
    _captureTimer = Timer.periodic(period, (_) => _captureOnce());
  }

  Future<void> _captureOnce() async {
    if (_capturing) return;
    if (_server?.hasViewer != true) return;
    _capturing = true;
    try {
      final boundaryContext = _captureKey.currentContext;
      if (boundaryContext == null) return;
      final renderObject = boundaryContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return;
      if (!renderObject.attached || !renderObject.hasSize) return;

      final view = View.maybeOf(boundaryContext);
      final dpr = widget.config.pixelRatio ?? view?.devicePixelRatio ?? 1.0;

      // Wait until end-of-frame so we don't capture mid-build.
      await SchedulerBinding.instance.endOfFrame;

      final image = await renderObject.toImage(pixelRatio: dpr);
      Uint8List? png;
      try {
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        png = bytes?.buffer.asUint8List();
      } finally {
        image.dispose();
      }
      if (png == null) return;

      final size = renderObject.size;
      final tree = walkTree(boundaryContext as Element);

      _server?.sendFrame({
        'type': 'frame',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'screenshot': base64Encode(png),
        'devicePixelRatio': dpr,
        'screenSize': {'w': size.width, 'h': size.height},
        'tree': tree,
      });
    } catch (e, st) {
      debugPrint('[widgetation] capture failed: $e\n$st');
    } finally {
      _capturing = false;
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
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
