import 'package:flutter/material.dart';

import 'tokens.dart';

/// Widgetation reticle mark — outer ring + center dot, optional crosshair ticks.
/// The select-mode glyph rendered as a crisp vector logo.
class WidgetationMark extends StatelessWidget {
  final double size;
  final Color color;
  final bool ticks;
  const WidgetationMark({super.key, this.size = 16, this.color = AppColors.ink, this.ticks = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ReticlePainter(color: color, ticks: ticks),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final Color color;
  final bool ticks;
  _ReticlePainter({required this.color, required this.ticks});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.10).clamp(1.0, 2.4)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r * 0.78, ring);

    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(cx, cy), r * 0.20, dot);

    if (ticks) {
      final tick = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = (size.width * 0.10).clamp(1.0, 2.4)
        ..strokeCap = StrokeCap.round;
      final inner = r * 0.92;
      final outer = r;
      canvas.drawLine(Offset(cx, cy - inner), Offset(cx, cy - outer), tick);
      canvas.drawLine(Offset(cx, cy + inner), Offset(cx, cy + outer), tick);
      canvas.drawLine(Offset(cx - inner, cy), Offset(cx - outer, cy), tick);
      canvas.drawLine(Offset(cx + inner, cy), Offset(cx + outer, cy), tick);
    }
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.ticks != ticks;
}

/// Compact pill primary button — Action Blue, ~28px high.
class ButtonPrimary extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const ButtonPrimary({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      child: TextButton(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          minimumSize: const Size(0, 28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: AppType.toolbar.copyWith(color: AppColors.onPrimary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.onPrimary),
              const SizedBox(width: 5),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// White ghost button with hairline outline.
class ButtonSecondary extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const ButtonSecondary({super.key, required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      child: TextButton(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: const Size(0, 28),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.hairline, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppType.toolbar,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.ink),
              const SizedBox(width: 5),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Inline blue text link.
class TextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const TextLink({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Text(label, style: AppType.body.copyWith(color: AppColors.primary)),
      ),
    );
  }
}

/// Active-press scale(0.96) — desktop-app micro-interaction (subtler than 0.95).
class _PressScale extends StatefulWidget {
  final Widget child;
  const _PressScale({required this.child});
  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _down = true),
      onPointerUp: (_) => setState(() => _down = false),
      onPointerCancel: (_) => setState(() => _down = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        scale: _down ? 0.96 : 1,
        child: widget.child,
      ),
    );
  }
}

/// Inset card with hairline border + 12px radius — the standard panel.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BorderRadius? borderRadius;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color = AppColors.canvas,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.hairlineSoft, width: 1),
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

/// Thin horizontal divider.
class Hairline extends StatelessWidget {
  final double indent;
  const Hairline({super.key, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: indent),
      child: Container(height: 1, color: AppColors.hairlineSoft),
    );
  }
}
