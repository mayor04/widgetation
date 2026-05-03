import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Set of stroke icons used by the floating toolbar. Hand-ported from the
/// agentation web bundle so the package ships zero asset weight and zero
/// extra dependencies. All glyphs render into a 24×24 box.
enum ToolbarIcon { wand, pause, layout, eye, duplicate, trash, settings, close }

class ToolbarIconPainter extends CustomPainter {
  final ToolbarIcon icon;
  final Color color;
  final double strokeWidth;

  const ToolbarIconPainter({
    required this.icon,
    required this.color,
    this.strokeWidth = 1.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24.0;
    canvas.save();
    canvas.translate(
      (size.width - 24 * scale) / 2,
      (size.height - 24 * scale) / 2,
    );
    canvas.scale(scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    switch (icon) {
      case ToolbarIcon.wand:
        _wand(canvas, stroke, fill);
        break;
      case ToolbarIcon.pause:
        _pause(canvas, stroke);
        break;
      case ToolbarIcon.layout:
        _layout(canvas, stroke);
        break;
      case ToolbarIcon.eye:
        _eye(canvas, stroke);
        break;
      case ToolbarIcon.duplicate:
        _duplicate(canvas, stroke);
        break;
      case ToolbarIcon.trash:
        _trash(canvas, stroke);
        break;
      case ToolbarIcon.settings:
        _settings(canvas, stroke);
        break;
      case ToolbarIcon.close:
        _close(canvas, stroke);
        break;
    }
    canvas.restore();
  }

  void _wand(Canvas canvas, Paint stroke, Paint fill) {
    // Diamond sparkle at the top-right.
    final spark = Path()
      ..moveTo(17.5, 4.5)
      ..lineTo(18.6, 7.0)
      ..lineTo(21.0, 8.0)
      ..lineTo(18.6, 9.0)
      ..lineTo(17.5, 11.5)
      ..lineTo(16.4, 9.0)
      ..lineTo(14.0, 8.0)
      ..lineTo(16.4, 7.0)
      ..close();
    canvas.drawPath(spark, fill);
    // Wand stroke from bottom-left to the sparkle base.
    canvas.drawLine(const Offset(4.0, 20.0), const Offset(15.5, 8.5), stroke);
  }

  void _pause(Canvas canvas, Paint stroke) {
    final p = Paint.from(stroke)..strokeWidth = 2.0;
    canvas.drawLine(const Offset(9.5, 6.5), const Offset(9.5, 17.5), p);
    canvas.drawLine(const Offset(14.5, 6.5), const Offset(14.5, 17.5), p);
  }

  void _layout(Canvas canvas, Paint stroke) {
    final r = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4.5, 4.5, 15.0, 15.0),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(r, stroke);
    // Horizontal divider near the top.
    canvas.drawLine(const Offset(4.5, 9.5), const Offset(19.5, 9.5), stroke);
    // Vertical divider on the left half.
    canvas.drawLine(const Offset(10.0, 9.5), const Offset(10.0, 19.5), stroke);
  }

  void _eye(Canvas canvas, Paint stroke) {
    final almond = Path()
      ..moveTo(3.5, 12.0)
      ..cubicTo(6.5, 6.5, 9.5, 5.0, 12.0, 5.0)
      ..cubicTo(14.5, 5.0, 17.5, 6.5, 20.5, 12.0)
      ..cubicTo(17.5, 17.5, 14.5, 19.0, 12.0, 19.0)
      ..cubicTo(9.5, 19.0, 6.5, 17.5, 3.5, 12.0)
      ..close();
    canvas.drawPath(almond, stroke);
    canvas.drawCircle(const Offset(12.0, 12.0), 2.6, stroke);
  }

  void _duplicate(Canvas canvas, Paint stroke) {
    // Back square (top-right).
    final back = RRect.fromRectAndRadius(
      const Rect.fromLTWH(9.0, 4.0, 11.0, 11.0),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(back, stroke);
    // Front square (bottom-left), drawn last so corners overlap cleanly.
    final front = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4.0, 9.0, 11.0, 11.0),
      const Radius.circular(2.0),
    );
    final clear = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;
    // Punch a hole for visual separation, then re-stroke.
    canvas.saveLayer(const Rect.fromLTWH(0, 0, 24, 24), Paint());
    canvas.drawRRect(back, stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.0, 9.0, 11.0, 11.0).inflate(0.6),
        const Radius.circular(2.6),
      ),
      clear,
    );
    canvas.restore();
    canvas.drawRRect(front, stroke);
  }

  void _trash(Canvas canvas, Paint stroke) {
    // Lid + handle.
    canvas.drawLine(const Offset(4.0, 6.5), const Offset(20.0, 6.5), stroke);
    final handle = Path()
      ..moveTo(9.5, 6.5)
      ..lineTo(9.5, 4.5)
      ..lineTo(14.5, 4.5)
      ..lineTo(14.5, 6.5);
    canvas.drawPath(handle, stroke);
    // Bin body.
    final body = Path()
      ..moveTo(6.5, 7.0)
      ..lineTo(7.5, 19.5)
      ..lineTo(16.5, 19.5)
      ..lineTo(17.5, 7.0);
    canvas.drawPath(body, stroke);
    // Vertical strokes inside the bin.
    canvas.drawLine(const Offset(10.0, 10.0), const Offset(10.0, 17.0), stroke);
    canvas.drawLine(const Offset(14.0, 10.0), const Offset(14.0, 17.0), stroke);
  }

  void _settings(Canvas canvas, Paint stroke) {
    final teeth = Path();
    const cx = 12.0, cy = 12.0;
    const inner = 6.5, outer = 9.0;
    const teethCount = 8;
    for (var i = 0; i < teethCount; i++) {
      final a0 = (i / teethCount) * 2 * math.pi;
      final a1 = ((i + 0.35) / teethCount) * 2 * math.pi;
      final a2 = ((i + 0.65) / teethCount) * 2 * math.pi;
      final a3 = ((i + 1) / teethCount) * 2 * math.pi;
      Offset onR(double r, double a) => Offset(cx + r * math.cos(a), cy + r * math.sin(a));
      if (i == 0) teeth.moveTo(onR(inner, a0).dx, onR(inner, a0).dy);
      teeth.lineTo(onR(inner, a1).dx, onR(inner, a1).dy);
      teeth.lineTo(onR(outer, a1).dx, onR(outer, a1).dy);
      teeth.lineTo(onR(outer, a2).dx, onR(outer, a2).dy);
      teeth.lineTo(onR(inner, a2).dx, onR(inner, a2).dy);
      teeth.lineTo(onR(inner, a3).dx, onR(inner, a3).dy);
    }
    teeth.close();
    canvas.drawPath(teeth, stroke);
    canvas.drawCircle(const Offset(cx, cy), 2.6, stroke);
  }

  void _close(Canvas canvas, Paint stroke) {
    canvas.drawLine(const Offset(7.0, 7.0), const Offset(17.0, 17.0), stroke);
    canvas.drawLine(const Offset(7.0, 17.0), const Offset(17.0, 7.0), stroke);
  }

  @override
  bool shouldRepaint(covariant ToolbarIconPainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}
