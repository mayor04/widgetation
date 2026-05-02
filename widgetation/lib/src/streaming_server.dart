import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Minimal HTTP/WebSocket server for the widgetation streamer.
///
/// Hosts at most one active viewer at a time. Non-WebSocket requests get a
/// JSON health probe so users can `curl` to confirm the server is alive.
///
/// Currently negotiated:
///   server -> client on upgrade: `{"type": "hello", "name": "...", "version": 1}`
///
/// Live framing (`focus`/`frame` messages) arrives in subsequent commits.
class StreamingServer {
  final String host;
  final int port;
  final String name;

  HttpServer? _server;
  WebSocket? _socket;

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
      (dynamic _) {
        // Inbound message handling lands in the next commit.
      },
      onDone: () {
        if (identical(_socket, ws)) _socket = null;
      },
      onError: (Object e) {
        debugPrint('[widgetation] socket error: $e');
      },
      cancelOnError: true,
    );
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
