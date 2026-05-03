import 'package:flutter/widgets.dart';

import '../state/edits_store.dart';
import '../state/widgetation_store.dart';
import '../toolbar/toolbar_icons.dart';
import 'edit_chat_box.dart';
import 'edit_index_bubble.dart';

/// Renders all committed edit bubbles plus the active chat box (if any).
/// Mounted by [Widgetation] above the selection overlay so bubbles sit on
/// top of highlights and the chat box on top of bubbles. Empty regions of
/// this layer don't capture pointer events — taps fall through to the
/// underlying select-mode gesture layer (which calls [EditsStore.shake]
/// when a draft is open instead of moving the selection).
class EditsLayer extends StatelessWidget {
  const EditsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: StoreBuilder<EditsStore, EditsState>(
        builder: (context, state) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final edit in state.edits)
                EditIndexBubble(key: ValueKey(edit.id), edit: edit),
              if (state.draft != null && !state.draft!.isEditing)
                _DraftPlusBubble(cursor: state.draft!.cursor),
              if (state.draft != null)
                EditChatBox(
                  key: ValueKey('chatbox:${state.draft!.editingId ?? '__new__'}'),
                  draft: state.draft!,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Cursor-anchored `+` bubble shown while a brand-new draft is open.
/// Replaces the eventual numbered bubble that appears on commit.
class _DraftPlusBubble extends StatelessWidget {
  final Offset cursor;
  const _DraftPlusBubble({required this.cursor});

  static const double _size = 28;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: cursor.dx - _size / 2,
      top: cursor.dy - _size / 2,
      child: IgnorePointer(
        child: Container(
          width: _size,
          height: _size,
          decoration: const BoxDecoration(
            color: Color(0xFF0091EA),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Color(0x33000000)),
            ],
          ),
          child: CustomPaint(
            painter: ToolbarIconPainter(
              icon: ToolbarIcon.plus,
              color: const Color(0xFFFFFFFF),
              strokeWidth: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
