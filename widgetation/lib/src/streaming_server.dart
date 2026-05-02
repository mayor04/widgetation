import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Minimal WebSocket server that hosts at most one active viewer at a time.
///
/// The protocol is JSON-only:
///   client -> server: {"type": "focus", "focused": true|false}
///                     {"type": "hello", "fps": 8}
///   server -> client: `{"type": "hello", "name": "...", "version": 1}`
///                     `{"type": "frame", "timestamp": ..., "screenshot": "(base64 PNG)",`
///                     ` "devicePixelRatio": 2.0,`
///                     ` "screenSize": {"w": 390, "h": 844},`
///                     ` "tree": [...]}`
class StreamingServer {
  final String host;
  final int port;
  final String name;

  HttpServer? _server;
  WebSocket? _socket;

  /// Fired when the focus state of the connected viewer changes (or when a
  /// viewer connects/disconnects). The bool reflects "should the streamer
  /// be capturing right now?" — i.e. true only when a viewer is connected
  /// AND focused.
  final ValueNotifier<bool> shouldCapture = ValueNotifier(false);

  /// Last requested fps from the viewer, or null to use server default.
  int? requestedFps;

  StreamingServer({
    required this.host,
    required this.port,
    required this.name,
  });

  Future<void> start() async {
    _server = await HttpServer.bind(host, port, shared: true);
    _server!.listen(_handleRequest, onError: (Object e, StackTrace st) {
      debugPrint('[widgetation] server error: $e');
    });
    debugPrint('[widgetation] listening on ws://$host:$port');
  }

  Future<void> stop() async {
    await _socket?.close();
    _socket = null;
    await _server?.close(force: true);
    _server = null;
    shouldCapture.value = false;
  }

  bool get hasViewer => _socket != null;

  Future<void> _handleRequest(HttpRequest req) async {
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      try {
        final ws = await WebSocketTransformer.upgrade(req);
        _onSocket(ws);
      } catch (e) {
        debugPrint('[widgetation] upgrade failed: $e');
      }
      return;
    }
    // Tiny health endpoint so users can curl / browse to check it's alive.
    req.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'name': name, 'protocol': 'widgetation/1'}));
    await req.response.close();
  }

  void _onSocket(WebSocket ws) {
    if (_socket != null) {
      // Only one viewer at a time — boot the older one.
      _socket!.close(WebSocketStatus.policyViolation, 'replaced');
    }
    _socket = ws;
    _send({'type': 'hello', 'name': name, 'version': 1});
    ws.listen(
      (dynamic data) {
        if (data is! String) return;
        try {
          final msg = jsonDecode(data) as Map<String, dynamic>;
          _onMessage(msg);
        } catch (e) {
          debugPrint('[widgetation] bad message: $e');
        }
      },
      onDone: () {
        if (identical(_socket, ws)) {
          _socket = null;
          requestedFps = null;
          shouldCapture.value = false;
        }
      },
      onError: (Object e) {
        debugPrint('[widgetation] socket error: $e');
      },
      cancelOnError: true,
    );
    // New viewer assumed unfocused until it tells us otherwise.
    shouldCapture.value = false;
  }

  void _onMessage(Map<String, dynamic> msg) {
    switch (msg['type']) {
      case 'focus':
        final focused = msg['focused'] == true;
        shouldCapture.value = focused && _socket != null;
      case 'hello':
        final fps = msg['fps'];
        if (fps is int) requestedFps = fps;
    }
  }

  void sendFrame(Map<String, dynamic> frame) {
    final s = _socket;
    if (s == null) return;
    _send(frame, socket: s);
  }

  void _send(Map<String, dynamic> obj, {WebSocket? socket}) {
    final s = socket ?? _socket;
    if (s == null) return;
    try {
      s.add(jsonEncode(obj));
    } catch (e) {
      debugPrint('[widgetation] send failed: $e');
    }
  }
}
