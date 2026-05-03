import 'package:flutter/widgets.dart';

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
    final disabled = widget.onTap == null;
    final activeColor = widget.activeColor ?? const Color(0xFF0091EA);
    final fg = disabled
        ? const Color(0x66FFFFFF)
        : widget.active
            ? activeColor
            : (_hover ? const Color(0xFFFFFFFF) : const Color(0xD9FFFFFF));
    final bg = widget.active
        ? activeColor.withAlpha(40)
        : (_hover && !disabled ? const Color(0x1FFFFFFF) : const Color(0x00000000));

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
            child: CustomPaint(
              painter: ToolbarIconPainter(icon: widget.icon, color: fg),
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
      color: const Color(0x33FFFFFF),
    );
  }
}
