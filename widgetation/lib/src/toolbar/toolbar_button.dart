import 'package:flutter/widgets.dart';

import '../theme.dart';
import 'toolbar_icons.dart';

/// 34×34 round icon button used inside the expanded toolbar pill. Visuals
/// match the agentation `controlButton` CSS: transparent base, hover tint
/// `rgba(255,255,255,0.12)`, active scale 0.92, disabled opacity 0.35.
class ToolbarControlButton extends StatefulWidget {
  final ToolbarIcon icon;
  final VoidCallback? onTap;
  final bool active;
  final Color? activeColor;

  const ToolbarControlButton({
    super.key,
    required this.icon,
    this.onTap,
    this.active = false,
    this.activeColor,
  });

  @override
  State<ToolbarControlButton> createState() => _ToolbarControlButtonState();
}

class _ToolbarControlButtonState extends State<ToolbarControlButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    final disabled = widget.onTap == null;
    final activeColor = widget.activeColor ?? theme.accent;
    final onSurface = theme.onSurface;
    final fg = disabled
        ? onSurface.withAlpha(102)
        : widget.active
            ? activeColor
            : (_hover ? onSurface : onSurface.withAlpha(217));
    final bg = widget.active
        ? activeColor.withAlpha(40)
        : (_hover && !disabled ? onSurface.withAlpha(31) : const Color(0x00000000));

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _down = true),
        onTapCancel: disabled ? null : () => setState(() => _down = false),
        onTapUp: disabled ? null : (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _down ? 0.92 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(
                  painter: ToolbarIconPainter(icon: widget.icon, color: fg),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1×16 vertical line used between the gear and the close button.
class ToolbarDivider extends StatelessWidget {
  const ToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: WidgetationTheme.of(context).divider,
    );
  }
}
