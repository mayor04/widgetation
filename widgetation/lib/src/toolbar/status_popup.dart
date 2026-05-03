import 'package:flutter/widgets.dart';

import '../config.dart';

/// Card surfaced above the toolbar via [OverlayPortal] when the user taps
/// the gear button. Shows the live config + connection state. Styling
/// matches the toolbar pill (#1A1A1A, soft shadow).
class ToolbarStatusPopup extends StatelessWidget {
  final WidgetationConfig config;
  final bool viewerConnected;
  final bool serverRunning;
  final VoidCallback onDismiss;

  const ToolbarStatusPopup({
    super.key,
    required this.config,
    required this.viewerConnected,
    required this.serverRunning,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 72,
          child: Container(
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x33000000)),
                BoxShadow(blurRadius: 16, offset: Offset(0, 4), color: Color(0x1A000000)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Title('Widgetation'),
                const SizedBox(height: 8),
                _Row(label: 'Mode', value: config.mode.name),
                _Row(label: 'Host', value: '${config.host}:${config.port}'),
                _Row(label: 'FPS', value: '${config.clampedFps}'),
                _Row(
                  label: 'Server',
                  value: serverRunning ? 'running' : 'idle',
                  dotColor: serverRunning
                      ? const Color(0xFF22C55E)
                      : const Color(0x66FFFFFF),
                ),
                _Row(
                  label: 'Viewer',
                  value: viewerConnected ? 'connected' : 'idle',
                  dotColor: viewerConnected
                      ? const Color(0xFF22C55E)
                      : const Color(0x66FFFFFF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      textDirection: TextDirection.ltr,
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? dotColor;
  const _Row({required this.label, required this.value, this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 11),
            textDirection: TextDirection.ltr,
          ),
          const Spacer(),
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
