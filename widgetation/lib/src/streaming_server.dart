import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'protocol/messages.dart';

/// Minimal WebSocket server that hosts at most one active viewer at a time.
///
/// Wire format is JSON; messages are modelled by [ViewerMessage] (incoming)
/// and [ServerMessage] (outgoing).
class StreamingServer {
  final String host;
  final int port;
  final String name;

  HttpServer? _server;
  WebSocket? _socket;

  /// True only when a viewer is connected AND focused — i.e. the streamer
  /// should be capturing right now.
  final ValueNotifier<bool> shouldCapture = ValueNotifier(false);

  /// Last requested fps from the viewer, or null to fall back to the
  /// server's configured default.
  final ValueNotifier<int?> requestedFps = ValueNotifier<int?>(null);

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
    send(ServerHello(name: name));
    ws.listen(
      (dynamic data) {
        if (data is! String) return;
        try {
          final json = jsonDecode(data) as Map<String, Object?>;
          final msg = ViewerMessage.parse(json);
          if (msg != null) _onMessage(msg);
        } catch (e) {
          debugPrint('[widgetation] bad message: $e');
        }
      },
      onDone: () {
        if (identical(_socket, ws)) {
          _socket = null;
          requestedFps.value = null;
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

  void _onMessage(ViewerMessage msg) {
    switch (msg) {
      case FocusMessage(:final focused):
        shouldCapture.value = focused && _socket != null;
      case HelloMessage(:final fps):
        if (fps != null) requestedFps.value = fps;
    }
  }

  void send(ServerMessage msg) {
    final s = _socket;
    if (s == null) return;
    try {
      s.add(jsonEncode(msg.toJson()));
    } catch (e) {
      debugPrint('[widgetation] send failed: $e');
    }
  }
}
