import 'package:flutter/widgets.dart';

/// Set of stroke icons used by the floating toolbar. Hand-ported from the
/// agentation web bundle so the package ships zero asset weight and zero
/// extra dependencies. All glyphs render into a 24×24 box.
enum ToolbarIcon { listSparkle, eye, duplicate, trash, settings, close, pencil, plus }

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
      case ToolbarIcon.listSparkle:
        _listSparkle(canvas, stroke);
        break;
      case ToolbarIcon.eye:
        _eye(canvas, stroke);
        break;
      case ToolbarIcon.duplicate:
        _duplicate(canvas, stroke);
        break;
      case ToolbarIcon.trash:
        _trash(canvas, fill);
        break;
      case ToolbarIcon.settings:
        _settings(canvas, stroke);
        break;
      case ToolbarIcon.close:
        _close(canvas, fill);
        break;
      case ToolbarIcon.pencil:
        _pencil(canvas, stroke);
        break;
      case ToolbarIcon.plus:
        _plus(canvas, stroke);
        break;
    }
    canvas.restore();
  }

  void _listSparkle(Canvas canvas, Paint stroke) {
    // Three left-aligned list lines (varying lengths).
    canvas.drawLine(const Offset(5.5, 6.75), const Offset(18.5, 6.75), stroke);
    canvas.drawLine(const Offset(5.5, 12.0), const Offset(11.5, 12.0), stroke);
    canvas.drawLine(const Offset(5.5, 17.25), const Offset(9.25, 17.25), stroke);
    // Four-pointed sparkle at (16, 16) with concave-curved sides.
    final sparkle = Path()
      ..moveTo(16, 12.75)
      ..lineTo(16.5179, 13.9677)
      ..cubicTo(16.8078, 14.6494, 17.3506, 15.1922, 18.0323, 15.4821)
      ..lineTo(19.25, 16)
      ..lineTo(18.0323, 16.5179)
      ..cubicTo(17.3506, 16.8078, 16.8078, 17.3506, 16.5179, 18.0323)
      ..lineTo(16, 19.25)
      ..lineTo(15.4821, 18.0323)
      ..cubicTo(15.1922, 17.3506, 14.6494, 16.8078, 13.9677, 16.5179)
      ..lineTo(12.75, 16)
      ..lineTo(13.9677, 15.4821)
      ..cubicTo(14.6494, 15.1922, 15.1922, 14.6494, 15.4821, 13.9677)
      ..close();
    canvas.drawPath(sparkle, stroke);
  }

  void _eye(Canvas canvas, Paint stroke) {
    final almond = Path()
      ..moveTo(3.91752, 12.7539)
      ..cubicTo(3.65127, 12.2996, 3.65037, 11.7515, 3.9149, 11.2962)
      ..cubicTo(4.9042, 9.59346, 7.72688, 5.49994, 12, 5.49994)
      ..cubicTo(16.2731, 5.49994, 19.0958, 9.59346, 20.0851, 11.2962)
      ..cubicTo(20.3496, 11.7515, 20.3487, 12.2996, 20.0825, 12.7539)
      ..cubicTo(19.0908, 14.4459, 16.2694, 18.4999, 12, 18.4999)
      ..cubicTo(7.73064, 18.4999, 4.90918, 14.4459, 3.91752, 12.7539)
      ..close();
    canvas.drawPath(almond, stroke);
    final pupil = Path()
      ..moveTo(12, 14.8261)
      ..cubicTo(13.5608, 14.8261, 14.8261, 13.5608, 14.8261, 12)
      ..cubicTo(14.8261, 10.4392, 13.5608, 9.17392, 12, 9.17392)
      ..cubicTo(10.4392, 9.17392, 9.17391, 10.4392, 9.17391, 12)
      ..cubicTo(9.17391, 13.5608, 10.4392, 14.8261, 12, 14.8261)
      ..close();
    canvas.drawPath(pupil, stroke);
  }

  void _duplicate(Canvas canvas, Paint stroke) {
    // Front rounded rect (bottom-left), full outline.
    final front = RRect.fromRectAndRadius(
      const Rect.fromLTRB(4.75, 9.75, 14.25, 19.25),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(front, stroke);
    // Back rect — only the visible top + right edges, ending behind the
    // front rect's top-left corner. Drawn open (not closed) so we don't
    // stroke a phantom diagonal.
    final back = Path()
      ..moveTo(17.25, 14.25)
      ..lineTo(17.75, 14.25)
      ..cubicTo(18.5784, 14.25, 19.25, 13.5784, 19.25, 12.75)
      ..lineTo(19.25, 6.25)
      ..cubicTo(19.25, 5.42157, 18.5784, 4.75, 17.75, 4.75)
      ..lineTo(11.25, 4.75)
      ..cubicTo(10.4216, 4.75, 9.75, 5.42157, 9.75, 6.25)
      ..lineTo(9.75, 6.75);
    canvas.drawPath(back, stroke);
  }

  void _trash(Canvas canvas, Paint fill) {
    // Filled compound path: outer outline, inner cutout, two streaks.
    // Even-odd rule gives the hollow-bin look with visible streaks inside.
    final path = Path()..fillType = PathFillType.evenOdd;
    // Outer trash outline.
    path
      ..moveTo(13.5, 4)
      ..cubicTo(14.7426, 4, 15.75, 5.00736, 15.75, 6.25)
      ..lineTo(15.75, 7)
      ..lineTo(18.5, 7)
      ..cubicTo(18.9142, 7, 19.25, 7.33579, 19.25, 7.75)
      ..cubicTo(19.25, 8.16421, 18.9142, 8.5, 18.5, 8.5)
      ..lineTo(17.9678, 8.5)
      ..lineTo(17.6328, 16.2217)
      ..cubicTo(17.61, 16.7475, 17.5912, 17.1861, 17.5469, 17.543)
      ..cubicTo(17.5015, 17.9087, 17.4225, 18.2506, 17.2461, 18.5723)
      ..cubicTo(16.9747, 19.0671, 16.5579, 19.4671, 16.0518, 19.7168)
      ..cubicTo(15.7227, 19.8791, 15.3772, 19.9422, 15.0098, 19.9717)
      ..cubicTo(14.6514, 20.0004, 14.2126, 20, 13.6865, 20)
      ..lineTo(10.3135, 20)
      ..cubicTo(9.78735, 20, 9.34856, 20.0004, 8.99023, 19.9717)
      ..cubicTo(8.62278, 19.9422, 8.27729, 19.8791, 7.94824, 19.7168)
      ..cubicTo(7.44205, 19.4671, 7.02532, 19.0671, 6.75391, 18.5723)
      ..cubicTo(6.57751, 18.2506, 6.49853, 17.9087, 6.45312, 17.543)
      ..cubicTo(6.40883, 17.1861, 6.39005, 16.7475, 6.36719, 16.2217)
      ..lineTo(6.03223, 8.5)
      ..lineTo(5.5, 8.5)
      ..cubicTo(5.08579, 8.5, 4.75, 8.16421, 4.75, 7.75)
      ..cubicTo(4.75, 7.33579, 5.08579, 7, 5.5, 7)
      ..lineTo(8.25, 7)
      ..lineTo(8.25, 6.25)
      ..cubicTo(8.25, 5.00736, 9.25736, 4, 10.5, 4)
      ..close();
    // Lid notch — 4.5×1.5 cap above the bin.
    path
      ..moveTo(10.5, 5.5)
      ..cubicTo(10.0858, 5.5, 9.75, 5.83579, 9.75, 6.25)
      ..lineTo(9.75, 7)
      ..lineTo(14.25, 7)
      ..lineTo(14.25, 6.25)
      ..cubicTo(14.25, 5.83579, 13.9142, 5.5, 13.5, 5.5)
      ..close();
    // Inner cutout — leaves only the bin "wall" visible.
    path
      ..moveTo(7.86621, 16.1562)
      ..cubicTo(7.89013, 16.7063, 7.90624, 17.0751, 7.94141, 17.3584)
      ..cubicTo(7.97545, 17.6326, 8.02151, 17.7644, 8.06934, 17.8516)
      ..cubicTo(8.19271, 18.0763, 8.38239, 18.2577, 8.6123, 18.3711)
      ..cubicTo(8.70153, 18.4151, 8.83504, 18.4545, 9.11035, 18.4766)
      ..cubicTo(9.39482, 18.4994, 9.76335, 18.5, 10.3135, 18.5)
      ..lineTo(13.6865, 18.5)
      ..cubicTo(14.2367, 18.5, 14.6052, 18.4994, 14.8896, 18.4766)
      ..cubicTo(15.165, 18.4545, 15.2985, 18.4151, 15.3877, 18.3711)
      ..cubicTo(15.6176, 18.2577, 15.8073, 18.0763, 15.9307, 17.8516)
      ..cubicTo(15.9785, 17.7644, 16.0245, 17.6326, 16.0586, 17.3584)
      ..cubicTo(16.0938, 17.0751, 16.1099, 16.7063, 16.1338, 16.1562)
      ..lineTo(16.4668, 8.5)
      ..lineTo(7.5332, 8.5)
      ..close();
    // Left vertical streak.
    path
      ..moveTo(9.97656, 10.75)
      ..cubicTo(10.3906, 10.7371, 10.7371, 11.0626, 10.75, 11.4766)
      ..lineTo(10.875, 15.4766)
      ..cubicTo(10.8879, 15.8906, 10.5624, 16.2371, 10.1484, 16.25)
      ..cubicTo(9.73443, 16.2629, 9.38794, 15.9374, 9.375, 15.5234)
      ..lineTo(9.25, 11.5234)
      ..cubicTo(9.23706, 11.1094, 9.56255, 10.7629, 9.97656, 10.75)
      ..close();
    // Right vertical streak.
    path
      ..moveTo(14.0244, 10.75)
      ..cubicTo(14.4384, 10.7635, 14.7635, 11.1105, 14.75, 11.5244)
      ..lineTo(14.6201, 15.5244)
      ..cubicTo(14.6066, 15.9384, 14.2596, 16.2634, 13.8457, 16.25)
      ..cubicTo(13.4317, 16.2365, 13.1067, 15.8896, 13.1201, 15.4756)
      ..lineTo(13.251, 11.4756)
      ..cubicTo(13.2645, 11.0617, 13.6105, 10.7366, 14.0244, 10.75)
      ..close();
    canvas.drawPath(path, fill);
  }

  void _settings(Canvas canvas, Paint stroke) {
    // 8-tooth gear: cubic curves between 16 anchors give the soft tooth shape
    // (vs. the pinwheel a straight-line approximation produces).
    final gear = Path()
      ..moveTo(10.6504, 5.81117)
      ..cubicTo(10.9939, 4.39628, 13.0061, 4.39628, 13.3496, 5.81117)
      ..cubicTo(13.5715, 6.72517, 14.6187, 7.15891, 15.4219, 6.66952)
      ..cubicTo(16.6652, 5.91193, 18.0881, 7.33479, 17.3305, 8.57815)
      ..cubicTo(16.8411, 9.38134, 17.2748, 10.4285, 18.1888, 10.6504)
      ..cubicTo(19.6037, 10.9939, 19.6037, 13.0061, 18.1888, 13.3496)
      ..cubicTo(17.2748, 13.5715, 16.8411, 14.6187, 17.3305, 15.4219)
      ..cubicTo(18.0881, 16.6652, 16.6652, 18.0881, 15.4219, 17.3305)
      ..cubicTo(14.6187, 16.8411, 13.5715, 17.2748, 13.3496, 18.1888)
      ..cubicTo(13.0061, 19.6037, 10.9939, 19.6037, 10.6504, 18.1888)
      ..cubicTo(10.4285, 17.2748, 9.38135, 16.8411, 8.57815, 17.3305)
      ..cubicTo(7.33479, 18.0881, 5.91193, 16.6652, 6.66952, 15.4219)
      ..cubicTo(7.15891, 14.6187, 6.72517, 13.5715, 5.81117, 13.3496)
      ..cubicTo(4.39628, 13.0061, 4.39628, 10.9939, 5.81117, 10.6504)
      ..cubicTo(6.72517, 10.4285, 7.15891, 9.38134, 6.66952, 8.57815)
      ..cubicTo(5.91193, 7.33479, 7.33479, 5.91192, 8.57815, 6.66952)
      ..cubicTo(9.38135, 7.15891, 10.4285, 6.72517, 10.6504, 5.81117)
      ..close();
    canvas.drawPath(gear, stroke);
    canvas.drawCircle(const Offset(12, 12), 2.5, stroke);
  }

  void _close(Canvas canvas, Paint fill) {
    // Filled "thick X" with rounded caps — matches the agentation glyph.
    final x = Path()
      ..moveTo(16.7198, 6.21973)
      ..cubicTo(17.0127, 5.92683, 17.4874, 5.92683, 17.7803, 6.21973)
      ..cubicTo(18.0732, 6.51262, 18.0732, 6.9874, 17.7803, 7.28027)
      ..lineTo(13.0606, 12)
      ..lineTo(17.7803, 16.7197)
      ..cubicTo(18.0732, 17.0126, 18.0732, 17.4874, 17.7803, 17.7803)
      ..cubicTo(17.4875, 18.0731, 17.0127, 18.0731, 16.7198, 17.7803)
      ..lineTo(12.0001, 13.0605)
      ..lineTo(7.28033, 17.7803)
      ..cubicTo(6.98746, 18.0731, 6.51268, 18.0731, 6.21979, 17.7803)
      ..cubicTo(5.92689, 17.4874, 5.92689, 17.0126, 6.21979, 16.7197)
      ..lineTo(10.9395, 12)
      ..lineTo(6.21979, 7.28027)
      ..cubicTo(5.92689, 6.98738, 5.92689, 6.51262, 6.21979, 6.21973)
      ..cubicTo(6.51268, 5.92683, 6.98744, 5.92683, 7.28033, 6.21973)
      ..lineTo(12.0001, 10.9395)
      ..close();
    canvas.drawPath(x, fill);
  }

  void _pencil(Canvas canvas, Paint stroke) {
    // Body of the pencil — diagonal from upper-right tip to lower-left point.
    final body = Path()
      ..moveTo(15.5, 4.5)
      ..lineTo(19.5, 8.5)
      ..lineTo(8.5, 19.5)
      ..lineTo(4.5, 19.5)
      ..lineTo(4.5, 15.5)
      ..close();
    canvas.drawPath(body, stroke);
    // Ferrule line separating eraser/tip from the body.
    canvas.drawLine(const Offset(13.0, 7.0), const Offset(17.0, 11.0), stroke);
  }

  void _plus(Canvas canvas, Paint stroke) {
    canvas.drawLine(const Offset(12.0, 6.0), const Offset(12.0, 18.0), stroke);
    canvas.drawLine(const Offset(6.0, 12.0), const Offset(18.0, 12.0), stroke);
  }

  @override
  bool shouldRepaint(covariant ToolbarIconPainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}
