import 'package:flutter/material.dart';

import 'connection.dart';

class InspectorPage extends StatefulWidget {
  const InspectorPage({super.key});

  @override
  State<InspectorPage> createState() => _InspectorPageState();
}

class _InspectorPageState extends State<InspectorPage> {
  final _connection = ConnectionController();
  final _hostController = TextEditingController(text: '127.0.0.1');
  final _portController = TextEditingController(text: '7321');

  @override
  void dispose() {
    _connection.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<String?>(
          valueListenable: _connection.serverName,
          builder: (context, name, _) => Text(
            name == null ? 'Widgetation Viewer' : 'Widgetation • $name',
          ),
        ),
        actions: [_connectionBar()],
      ),
      body: const Center(child: Text('Viewport coming soon')),
    );
  }

  Widget _connectionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ValueListenableBuilder<ConnectionStatus>(
        valueListenable: _connection.status,
        builder: (context, status, _) {
          final connected = status == ConnectionStatus.connected;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _hostController,
                  enabled: !connected,
                  decoration: const InputDecoration(
                    labelText: 'Host',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _portController,
                  enabled: !connected,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (status == ConnectionStatus.connecting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (connected)
                FilledButton.tonal(
                  onPressed: _connection.disconnect,
                  child: const Text('Disconnect'),
                )
              else
                FilledButton(
                  onPressed: _connect,
                  child: const Text('Connect'),
                ),
              const SizedBox(width: 8),
              _statusDot(status),
            ],
          );
        },
      ),
    );
  }

  Widget _statusDot(ConnectionStatus s) {
    final color = switch (s) {
      ConnectionStatus.connected => Colors.green,
      ConnectionStatus.connecting => Colors.amber,
      ConnectionStatus.error => Colors.red,
      ConnectionStatus.disconnected => Colors.grey,
    };
    return Tooltip(
      message: s.name,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  void _connect() {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 7321;
    _connection.connect(host, port);
  }
}
