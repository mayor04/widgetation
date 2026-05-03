import 'package:flutter/widgets.dart';

import '../state/edits_store.dart';
import '../state/widgetation_store.dart';
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

  static const double _size = 28;

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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0091EA),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Color(0x33000000)),
        ],
      ),
      alignment: Alignment.center,
      child: hover
          ? SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: ToolbarIconPainter(
                  icon: ToolbarIcon.pencil,
                  color: const Color(0xFFFFFFFF),
                  strokeWidth: 1.8,
                ),
              ),
            )
          : Text(
              '$number',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
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
    final label = edit.nodes.isEmpty ? '' : formatNodeLabel(edit.nodes.first);
    return IgnorePointer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xEE111111),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x33000000)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFB3B3B3),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textDirection: TextDirection.ltr,
              ),
            if (label.isNotEmpty) const SizedBox(height: 4),
            Text(
              edit.text,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
