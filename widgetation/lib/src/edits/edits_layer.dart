import 'package:flutter/widgets.dart';

import '../state/edits_store.dart';
import '../state/widgetation_store.dart';
import '../theme.dart';
import '../toolbar/toolbar_icons.dart';
import 'edit_chat_box.dart';
import 'edit_index_bubble.dart';

/// Renders all committed edit bubbles plus the active chat box (if any).
/// Mounted by [Widgetation] above the selection overlay so bubbles sit on
/// top of highlights and the chat box on top of bubbles. Empty regions of
/// this layer don't capture pointer events — taps fall through to the
/// underlying select-mode gesture layer (which calls [EditsStore.shake]
/// when a draft is open instead of moving the selection).
///
/// The bubbles list and the active draft are observed independently so
/// opening or shaking the chat box never re-iterates the bubbles, and
/// committing/deleting an edit never disturbs the chat box.
class EditsLayer extends StatelessWidget {
  const EditsLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of<EditsStore>(context);
    return Positioned.fill(
      child: RepaintBoundary(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder<EditsListSlice>(
              valueListenable: store.list,
              builder: (context, slice, _) {
                if (slice.hidden || slice.edits.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final edit in slice.edits)
                      EditIndexBubble(key: ValueKey(edit.id), edit: edit),
                  ],
                );
              },
            ),
            ValueListenableBuilder<EditDraft?>(
              valueListenable: store.draft,
              builder: (context, draft, _) {
                if (draft == null) return const SizedBox.shrink();
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (!draft.isEditing) _DraftPlusBubble(cursor: draft.cursor),
                    EditChatBox(
                      key: ValueKey('chatbox:${draft.editingId ?? '__new__'}'),
                      draft: draft,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
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
    final theme = WidgetationTheme.of(context);
    return Positioned(
      left: cursor.dx - _size / 2,
      top: cursor.dy - _size / 2,
      child: IgnorePointer(
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: theme.accent,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(blurRadius: 6, offset: const Offset(0, 2), color: theme.shadow),
            ],
          ),
          child: CustomPaint(
            painter: ToolbarIconPainter(
              icon: ToolbarIcon.plus,
              color: theme.onAccent,
              strokeWidth: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
