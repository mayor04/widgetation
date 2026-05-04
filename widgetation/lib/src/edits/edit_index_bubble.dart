import 'package:flutter/widgets.dart';

import '../state/edits_store.dart';
import '../state/widgetation_store.dart';
import '../theme.dart';
import '../toolbar/toolbar_icons.dart';
import 'edit_label.dart';

/// Numbered circle anchored at [edit.cursor]. Idle: shows the edit
/// number. Hover: shows a pencil glyph plus a dark popover with the
/// widget label and edit text. Tap: re-opens the chat box for editing.
class EditIndexBubble extends StatefulWidget {
  final Edit edit;

  const EditIndexBubble({super.key, required this.edit});

  @override
  State<EditIndexBubble> createState() => _EditIndexBubbleState();
}

class _EditIndexBubbleState extends State<EditIndexBubble> {
  bool _hover = false;

  final double _size = 20;

  void _onTap() => context.read<EditsStore>().editExisting(widget.edit.id);

  @override
  Widget build(BuildContext context) {
    final cursor = widget.edit.cursor;
    return Positioned(
      left: cursor.dx - _size / 2,
      top: cursor.dy - _size / 2,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _Bubble(number: widget.edit.index, hover: _hover),
                if (_hover)
                  Positioned(
                    top: _size + 8,
                    left: -_size,
                    child: _HoverPopover(edit: widget.edit),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final int number;
  final bool hover;

  const _Bubble({required this.number, required this.hover});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.accent,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(blurRadius: 6, offset: const Offset(0, 2), color: theme.shadow)],
      ),
      alignment: Alignment.center,
      child: hover
          ? SizedBox(
              width: 14,
              height: 14,
              child: CustomPaint(
                painter: ToolbarIconPainter(
                  icon: ToolbarIcon.pencil,
                  color: theme.onAccent,
                  strokeWidth: 1.8,
                ),
              ),
            )
          : Text(
              '$number',
              style: TextStyle(color: theme.onAccent, fontSize: 10, fontWeight: FontWeight.w700),
              textDirection: TextDirection.ltr,
            ),
    );
  }
}

class _HoverPopover extends StatelessWidget {
  final Edit edit;

  const _HoverPopover({required this.edit});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    final label = edit.nodes.isEmpty ? '' : formatNodeLabel(edit.nodes.first);
    final fg = theme.brightness == Brightness.dark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFFFFFFFF);
    final fgMuted = theme.brightness == Brightness.dark
        ? const Color(0xFFB3B3B3)
        : const Color(0xFFD4D4D8);
    return IgnorePointer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 8, offset: const Offset(0, 2), color: theme.shadow)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(color: fgMuted, fontSize: 12, fontStyle: FontStyle.italic),
                textDirection: TextDirection.ltr,
              ),
            if (label.isNotEmpty) const SizedBox(height: 4),
            Text(
              edit.text,
              style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w500),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
