import 'package:flutter/widgets.dart';

import 'protocol/tree_node.dart' show TreeNode;

/// Pure-visual highlight layer painted on top of the app while select
/// mode is active. Does not hit-test (wrapped in [IgnorePointer]) — the
/// hosting [Widgetation] mounts its own gesture layer separately.
class SelectionHighlights extends StatelessWidget {
  final TreeNode? hover;
  final TreeNode? selected;

  const SelectionHighlights({
    super.key,
    required this.hover,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _SelectionPainter(hover: hover, selected: selected),
          child: const SizedBox.expand(),
        ),
      ),
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

/// Tiny label rendered above the selected rect: `type · file:line`.
class SelectionInfoChip extends StatelessWidget {
  final TreeNode hit;
  const SelectionInfoChip({super.key, required this.hit});

  @override
  Widget build(BuildContext context) {
    final loc = hit.file == null
        ? hit.type
        : '${hit.type}  ·  ${hit.file!.split('/').last}:${hit.line ?? '?'}';
    return Positioned(
      left: hit.rect.x,
      top: (hit.rect.y - 24).clamp(0.0, double.infinity),
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: const BoxDecoration(color: Color(0xEE0091EA)),
          child: Text(
            loc,
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
  }
}
