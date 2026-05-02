import 'package:flutter/material.dart';

import 'frame.dart' as proto;

/// Displays the streamed PNG inside a "device frame" border, with a
/// hover-to-inspect overlay drawn on top.
class ViewportView extends StatelessWidget {
  final proto.InspectorFrame? frame;
  final proto.TreeNode? selected;
  final ValueChanged<proto.TreeNode?> onHover;

  const ViewportView({
    super.key,
    required this.frame,
    required this.selected,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final f = frame;
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: f == null ? _placeholder(context) : _viewport(f),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Text(
      'Waiting for frames…\n\nConnect to a running widgetation streamer\nusing the Host/Port fields above.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _viewport(proto.InspectorFrame f) {
    final aspect = f.logicalSize.width / f.logicalSize.height;
    return AspectRatio(
      aspectRatio: aspect == 0 ? 0.5 : aspect,
      child: LayoutBuilder(builder: (context, constraints) {
        final scale = constraints.maxWidth / f.logicalSize.width;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 8),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(blurRadius: 24, color: Colors.black54),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: MouseRegion(
              onHover: (event) => _handleHover(event.localPosition, scale, f),
              onExit: (_) => onHover(null),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    f.png,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _OverlayPainter(
                        node: selected,
                        scale: scale,
                      ),
                    ),
                  ),
                  if (selected != null)
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: _SelectionTooltip(node: selected!),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _handleHover(Offset local, double scale, proto.InspectorFrame f) {
    final logicalX = local.dx / scale;
    final logicalY = local.dy / scale;
    final hit = proto.hitTest(f.tree, logicalX, logicalY);
    onHover(hit);
  }
}

class _OverlayPainter extends CustomPainter {
  final proto.TreeNode? node;
  final double scale;
  _OverlayPainter({required this.node, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final n = node;
    if (n == null) return;
    final rect = Rect.fromLTWH(n.x * scale, n.y * scale, n.w * scale, n.h * scale);
    final fill = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.18);
    final stroke = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, stroke);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.node != node || old.scale != scale;
}

class _SelectionTooltip extends StatelessWidget {
  final proto.TreeNode node;
  const _SelectionTooltip({required this.node});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                node.type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              Text(
                '${node.w.toStringAsFixed(0)} × ${node.h.toStringAsFixed(0)} '
                '@ (${node.x.toStringAsFixed(0)}, ${node.y.toStringAsFixed(0)})',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
