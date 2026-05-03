import 'package:flutter/widgets.dart';

import 'protocol/tree_node.dart' show TreeNode;
import 'state/hover_store.dart';
import 'state/selection_store.dart';
import 'state/widgetation_store.dart';

/// Pure-visual highlight layer painted on top of the app while select
/// mode is active. Does not hit-test (wrapped in [IgnorePointer]) — the
/// hosting [Widgetation] mounts its own gesture layer separately. Reads
/// hover and selection from ambient [StoreScope]s.
class SelectionHighlights extends StatelessWidget {
  const SelectionHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<SelectionStore, SelectionState>(
      builder: (context, selection) {
        return StoreBuilder<HoverStore, HoverState>(
          builder: (context, hover) {
            return Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SelectionPainter(
                    hover: hover.node,
                    selected: selection.primary,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SelectionPainter extends CustomPainter {
  final TreeNode? hover;
  final TreeNode? selected;
  _SelectionPainter({required this.hover, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    if (hover != null && hover != selected) {
      final r = _toRect(hover!);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x8833B5FF);
      canvas.drawRect(r, p);
    }
    if (selected != null) {
      final r = _toRect(selected!);
      canvas.drawRect(r, Paint()..color = const Color(0x2233B5FF));
      canvas.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF0091EA),
      );
    }
  }

  Rect _toRect(TreeNode n) =>
      Rect.fromLTWH(n.rect.x, n.rect.y, n.rect.w, n.rect.h);

  @override
  bool shouldRepaint(covariant _SelectionPainter old) =>
      old.hover != hover || old.selected != selected;
}

/// Tiny label rendered next to the cursor showing the hovered widget's type.
/// Reads hover state and primary selection from ambient [StoreScope]s; only
/// paints when there's a hover that isn't the same as the selected node.
class SelectionInfoChip extends StatelessWidget {
  const SelectionInfoChip({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<SelectionStore, SelectionState>(
      builder: (context, selection) {
        return StoreBuilder<HoverStore, HoverState>(
          builder: (context, hover) {
            final hit = hover.node;
            if (hit == null || hit == selection.primary) {
              return const SizedBox.shrink();
            }
            final cursor = hover.cursor;
            final double left;
            final double top;
            if (cursor != null) {
              left = (cursor.dx + 12).clamp(0.0, double.infinity);
              top = (cursor.dy - 28).clamp(0.0, double.infinity);
            } else {
              left = hit.rect.x;
              top = (hit.rect.y - 24).clamp(0.0, double.infinity);
            }
            return Positioned(
              left: left,
              top: top,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xEE111111),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hit.type,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
