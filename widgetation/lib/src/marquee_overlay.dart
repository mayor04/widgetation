import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Renders the live marquee selection rect while the user drags. Listens
/// to a [ValueListenable] so a drag updates only this leaf — the host
/// widgetation tree never rebuilds at pan-update frequency.
class MarqueeOverlay extends StatelessWidget {
  final ValueListenable<Rect?> rect;

  const MarqueeOverlay({super.key, required this.rect});

  @override
  Widget build(BuildContext context) {
    // Always Positioned.fill so this is a positioned child of the parent
    // Stack regardless of whether a marquee is active. A non-positioned
    // 0×0 SizedBox.shrink would collapse the parent Stack's size when
    // it has no other non-positioned children.
    return Positioned.fill(
      child: IgnorePointer(
        child: ValueListenableBuilder<Rect?>(
          valueListenable: rect,
          builder: (context, r, _) {
            if (r == null) return const SizedBox.shrink();
            return RepaintBoundary(
              child: CustomPaint(painter: _MarqueePainter(r)),
            );
          },
        ),
      ),
    );
  }
}

class _MarqueePainter extends CustomPainter {
  static const Color _green = Color(0xFF00C853);
  static const Color _greenFill = Color(0x3300C853);

  final Rect rect;
  _MarqueePainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(rect, Paint()..color = _greenFill);
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _green,
    );
  }

  @override
  bool shouldRepaint(covariant _MarqueePainter old) => old.rect != rect;
}
