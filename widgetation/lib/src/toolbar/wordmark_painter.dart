import 'package:flutter/widgets.dart';

/// Hand-traced "Widgetation" wordmark drawn into a 200×40 virtual box and
/// scaled to fit any [Size]. Mirrors the [ToolbarIconPainter] pattern so
/// the package keeps its zero-asset, zero-dependency posture. Italic
/// single-stroke script, no underline.
class WidgetationWordmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const WidgetationWordmarkPainter({
    required this.color,
    this.strokeWidth = 1.5,
  });

  static const double _vw = 200;
  static const double _vh = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / _vh;
    final drawnW = _vw * scale;
    canvas.save();
    canvas.translate((size.width - drawnW) / 2, 0);
    canvas.scale(scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Single flowing path. Coordinates assume baseline ~y=28, x-height
    // top ~y=14, ascenders to y=4, descenders to y=36. Letters slant
    // right ~10° via the curve handles, not a global transform.
    final p = Path();

    // W — italic zigzag with a leading flourish entry from the top.
    p
      ..moveTo(8, 8)
      ..cubicTo(8, 14, 10, 22, 12, 28)
      ..cubicTo(13, 24, 14, 18, 15, 14)
      ..cubicTo(15, 20, 17, 26, 19, 28)
      ..cubicTo(20, 24, 22, 18, 25, 12);

    // i — short italic stem, baseline tail flicks up to lead into d.
    p
      ..moveTo(28, 14)
      ..cubicTo(27, 20, 27, 26, 30, 28);

    // d — bowl + ascender. Opens with a soft incoming swash.
    p
      ..moveTo(42, 16)
      ..cubicTo(38, 13, 33, 16, 33, 22)
      ..cubicTo(33, 28, 39, 30, 42, 26)
      ..cubicTo(43, 22, 44, 16, 46, 6)
      ..cubicTo(45, 14, 44, 22, 44, 28);

    // g — bowl + curling descender.
    p
      ..moveTo(58, 16)
      ..cubicTo(54, 13, 49, 16, 49, 22)
      ..cubicTo(49, 28, 55, 30, 58, 26)
      ..cubicTo(58, 22, 58, 18, 58, 16)
      ..cubicTo(58, 22, 57, 30, 56, 34)
      ..cubicTo(55, 38, 50, 38, 48, 35);

    // e — open loop with exit flick.
    p
      ..moveTo(62, 22)
      ..cubicTo(68, 22, 71, 19, 70, 17)
      ..cubicTo(68, 14, 62, 16, 62, 22)
      ..cubicTo(62, 27, 67, 30, 71, 27);

    // t — italic stem with crossbar.
    p
      ..moveTo(82, 8)
      ..cubicTo(80, 16, 78, 24, 78, 28)
      ..cubicTo(78, 30, 80, 30, 82, 28)
      ..moveTo(76, 14)
      ..lineTo(86, 14);

    // a — bowl with vertical right side flowing into next letter.
    p
      ..moveTo(94, 16)
      ..cubicTo(89, 14, 86, 18, 87, 22)
      ..cubicTo(88, 27, 93, 28, 94, 24)
      ..cubicTo(94, 20, 94, 16, 94, 16)
      ..cubicTo(94, 22, 94, 26, 96, 28);

    // t — second t.
    p
      ..moveTo(104, 8)
      ..cubicTo(102, 16, 100, 24, 100, 28)
      ..cubicTo(100, 30, 102, 30, 104, 28)
      ..moveTo(98, 14)
      ..lineTo(108, 14);

    // i — short italic stem.
    p
      ..moveTo(112, 14)
      ..cubicTo(111, 20, 111, 26, 113, 28);

    // o — oval.
    p
      ..moveTo(122, 16)
      ..cubicTo(117, 16, 117, 28, 122, 28)
      ..cubicTo(127, 28, 127, 16, 122, 16);

    // n — italic hump.
    p
      ..moveTo(132, 28)
      ..cubicTo(132, 22, 133, 18, 134, 14)
      ..cubicTo(134, 18, 134, 22, 134, 26)
      ..cubicTo(134, 18, 138, 14, 142, 14)
      ..cubicTo(146, 14, 146, 20, 145, 28);

    canvas.drawPath(p, stroke);

    // Dots on the i's.
    final dot = Paint()..color = color;
    canvas.drawCircle(const Offset(28.5, 9), strokeWidth * 0.85, dot);
    canvas.drawCircle(const Offset(112.5, 9), strokeWidth * 0.85, dot);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WidgetationWordmarkPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
