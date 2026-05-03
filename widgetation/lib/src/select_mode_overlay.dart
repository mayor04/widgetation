import 'package:flutter/widgets.dart';

import 'protocol/tree_node.dart' show TreeNode;
import 'state/edits_store.dart';
import 'state/hover_store.dart';
import 'state/selection_store.dart';
import 'state/widgetation_store.dart';
import 'theme.dart';

/// Pure-visual highlight layer painted on top of the app while select
/// mode is active. Does not hit-test (wrapped in [IgnorePointer]) — the
/// hosting [Widgetation] mounts its own gesture layer separately. Reads
/// hover, selection, and the active draft (for marquee union rects) from
/// ambient [StoreScope]s.
class SelectionHighlights extends StatelessWidget {
  const SelectionHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = WidgetationTheme.of(context).accent;
    return StoreBuilder<SelectionStore, SelectionState>(
      builder: (context, selection) {
        return StoreBuilder<HoverStore, HoverState>(
          builder: (context, hover) {
            return StoreBuilder<EditsStore, EditsState>(
              builder: (context, edits) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SelectionPainter(
                        hover: hover.node,
                        selected: selection.primary,
                        unionRect: _resolveUnionRect(edits, selection),
                        accent: accent,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Prefer the draft's selectRect (only set on multi-node marquees and
  // restored when re-opening a multi-node edit). Fall back to a computed
  // union when SelectionStore holds multiple nodes but no draft is open
  // (e.g. just after committing a marquee edit).
  static Rect? _resolveUnionRect(EditsState edits, SelectionState selection) {
    final fromDraft = edits.draft?.selectRect;
    if (fromDraft != null) return fromDraft;
    if (selection.nodes.length < 2) return null;
    Rect? acc;
    for (final n in selection.nodes) {
      final r = Rect.fromLTWH(n.rect.x, n.rect.y, n.rect.w, n.rect.h);
      acc = acc == null ? r : acc.expandToInclude(r);
    }
    return acc;
  }
}

class _SelectionPainter extends CustomPainter {
  final TreeNode? hover;
  final TreeNode? selected;
  final Rect? unionRect;
  final Color accent;
  _SelectionPainter({
    required this.hover,
    required this.selected,
    required this.unionRect,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hover != null && hover != selected) {
      final r = _toRect(hover!);
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accent.withAlpha(0x88);
      canvas.drawRect(r, p);
    }
    final union = unionRect;
    if (union != null) {
      canvas.drawRect(union, Paint()..color = accent.withAlpha(0x22));
      canvas.drawRect(
        union,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = accent,
      );
    } else if (selected != null) {
      final r = _toRect(selected!);
      canvas.drawRect(r, Paint()..color = accent.withAlpha(0x22));
      canvas.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = accent,
      );
    }
  }

  Rect _toRect(TreeNode n) =>
      Rect.fromLTWH(n.rect.x, n.rect.y, n.rect.w, n.rect.h);

  @override
  bool shouldRepaint(covariant _SelectionPainter old) =>
      old.hover != hover ||
      old.selected != selected ||
      old.unionRect != unionRect ||
      old.accent != accent;
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
            final theme = WidgetationTheme.of(context);
            return Positioned(
              left: left,
              top: top,
              child: IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.surfaceElevated,
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
