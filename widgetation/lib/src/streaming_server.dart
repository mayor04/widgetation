import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Minimal HTTP/WebSocket server for the widgetation streamer.
///
/// In this revision the server only binds and answers a small JSON health
/// probe so users can `curl` it and confirm the streamer is alive.
/// WebSocket upgrade and the live framing protocol arrive in subsequent
/// commits.
class StreamingServer {
  final String host;
  final int port;
  final String name;

  HttpServer? _server;

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
    debugPrint('[widgetation] listening on http://$host:$port');
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest req) async {
    // Tiny health endpoint so users can curl / browse to check it's alive.
    req.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'name': name, 'protocol': 'widgetation/1'}));
    await req.response.close();
  }
}
