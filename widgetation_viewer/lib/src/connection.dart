import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'frame.dart';

enum ConnectionStatus { disconnected, connecting, connected, error }

/// Owns the WebSocket connection to a running widgetation streamer.
///
/// Surface area is intentionally tiny: connect / disconnect / setFocused +
/// listenable state (status, lastFrame, errorMessage).
class ConnectionController {
  final ValueNotifier<ConnectionStatus> status =
      ValueNotifier(ConnectionStatus.disconnected);
  final ValueNotifier<InspectorFrame?> lastFrame = ValueNotifier(null);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<String?> serverName = ValueNotifier(null);

  WebSocket? _socket;
  bool _focused = true;

  Future<void> connect(String host, int port) async {
    await disconnect();
    status.value = ConnectionStatus.connecting;
    errorMessage.value = null;
    final uri = Uri.parse('ws://$host:$port');
    try {
      final ws = await WebSocket.connect(uri.toString())
          .timeout(const Duration(seconds: 5));
      _socket = ws;
      status.value = ConnectionStatus.connected;
      _send({'type': 'hello', 'fps': 8});
      _send({'type': 'focus', 'focused': _focused});
      ws.listen(
        _onData,
        onDone: () {
          if (status.value != ConnectionStatus.error) {
            status.value = ConnectionStatus.disconnected;
          }
          _socket = null;
        },
        onError: (Object e) {
          errorMessage.value = e.toString();
          status.value = ConnectionStatus.error;
        },
        cancelOnError: true,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = ConnectionStatus.error;
    }
  }

  Future<void> disconnect() async {
    final s = _socket;
    _socket = null;
    if (s != null) {
      await s.close();
    }
    status.value = ConnectionStatus.disconnected;
    serverName.value = null;
  }

  void setFocused(bool focused) {
    if (_focused == focused) return;
    _focused = focused;
    _send({'type': 'focus', 'focused': focused});
  }

  void _onData(dynamic data) {
    if (data is! String) return;
    try {
      final msg = jsonDecode(data) as Map<String, dynamic>;
      switch (msg['type']) {
        case 'hello':
          serverName.value = msg['name'] as String?;
        case 'frame':
          lastFrame.value = InspectorFrame.fromJson(msg);
      }
    } catch (e) {
      debugPrint('[viewer] bad frame: $e');
    }
  }

  void _send(Map<String, dynamic> obj) {
    final s = _socket;
    if (s == null) return;
    try {
      s.add(jsonEncode(obj));
    } catch (e) {
      debugPrint('[viewer] send failed: $e');
    }
  }

  void dispose() {
    disconnect();
    status.dispose();
    lastFrame.dispose();
    errorMessage.dispose();
    serverName.dispose();
  }
}
