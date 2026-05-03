import 'package:flutter/material.dart';

import 'tokens.dart';

/// 4-spoke radial spike — the Ochestra brand mark.
class SpikeMark extends StatelessWidget {
  final double size;
  final Color color;
  const SpikeMark({super.key, this.size = 16, this.color = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SpikePainter(color)),
    );
  }
}

class _SpikePainter extends CustomPainter {
  final Color color;
  _SpikePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final long = size.width * 0.5;
    final wide = size.width * 0.12;

    // Vertical spike
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: wide, height: long * 2),
        const Radius.circular(1),
      ),
      paint,
    );
    // Horizontal spike
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: long * 2, height: wide),
        const Radius.circular(1),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpikePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Coral primary CTA.
class ButtonPrimary extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const ButtonPrimary({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primaryDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppType.button,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Cream secondary button with hairline outline.
class ButtonSecondary extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const ButtonSecondary({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.hairline, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppType.button,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Inverted cream button used on coral / dark surfaces.
class ButtonInverted extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const ButtonInverted({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppType.button,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Inline coral text link.
class TextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const TextLink({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppType.bodySm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// Pill badge.
class BadgePill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool uppercase;
  const BadgePill({
    super.key,
    required this.label,
    this.background = AppColors.surfaceCard,
    this.foreground = AppColors.ink,
    this.uppercase = false,
  });

  factory BadgePill.coral(String label) => BadgePill(
        label: label,
        background: AppColors.primary,
        foreground: AppColors.onPrimary,
        uppercase: true,
      );

  @override
  Widget build(BuildContext context) {
    final base = uppercase ? AppType.captionUppercase : AppType.caption;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: base.copyWith(color: foreground)),
    );
  }
}

/// Generic cream feature card.
class CreamCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  const CreamCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.color = AppColors.surfaceCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

/// Dark navy surface card.
class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const DarkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

/// Cream card with hairline outline (used for pricing tiers).
class OutlinedCreamCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const OutlinedCreamCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

/// Section band with consistent vertical padding.
class SectionBand extends StatelessWidget {
  final Widget child;
  final Color color;
  final double maxWidth;
  const SectionBand({
    super.key,
    required this.child,
    this.color = AppColors.canvas,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.section,
        horizontal: AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Section eyebrow (small uppercase label above a heading).
class SectionEyebrow extends StatelessWidget {
  final String label;
  final Color color;
  const SectionEyebrow({
    super.key,
    required this.label,
    this.color = AppColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SpikeMark(size: 12, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: AppType.captionUppercase.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Status dot (green / amber / coral) used in the connector tiles.
class StatusDot extends StatelessWidget {
  final Color color;
  const StatusDot({super.key, this.color = AppColors.success});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
