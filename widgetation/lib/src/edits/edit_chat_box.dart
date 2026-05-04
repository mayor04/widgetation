import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../state/edits_store.dart';
import '../state/widgetation_store.dart';
import '../theme.dart';
import '../toolbar/toolbar_icons.dart';
import 'chat_box_position.dart';
import 'edit_label.dart';

/// Floating chat surface anchored to the [EditDraft.cursor]. Hosts the
/// widget label, a single-line text input, Cancel + Add/Save buttons,
/// and an optional trash icon when editing an existing entry.
///
/// Position is recomputed each frame from the screen size + cursor; the
/// box self-shifts to stay on-screen. Listens for [EditDraft.shakeNonce]
/// changes to trigger a brief horizontal nudge.
class EditChatBox extends StatefulWidget {
  final EditDraft draft;

  const EditChatBox({super.key, required this.draft});

  @override
  State<EditChatBox> createState() => _EditChatBoxState();
}

class _EditChatBoxState extends State<EditChatBox>
    with TickerProviderStateMixin {
  static const Size _boxSize = Size(288, 116);

  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  late final AnimationController _shakeCtrl;

  EditsStore? _store;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.draft.text);
    _focus = FocusNode();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _ctrl.addListener(_publishHasText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = context.read<EditsStore>();
    _publishHasText();
  }

  @override
  void didUpdateWidget(covariant EditChatBox old) {
    super.didUpdateWidget(old);
    if (old.draft.shakeNonce != widget.draft.shakeNonce) {
      _shakeCtrl.forward(from: 0);
    }
    // Keep controller text in sync on identity swap (e.g. editing flips).
    if (old.draft.editingId != widget.draft.editingId &&
        _ctrl.text != widget.draft.text) {
      _ctrl.text = widget.draft.text;
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_publishHasText);
    _store?.setHasDraftText(false);
    _ctrl.dispose();
    _focus.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _publishHasText() {
    _store?.setHasDraftText(_ctrl.text.trim().isNotEmpty);
  }

  void _commit() => _store?.commitDraft(_ctrl.text);
  void _cancel() => _store?.cancelDraft();
  void _delete() {
    final id = widget.draft.editingId;
    if (id != null) _store?.delete(id);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = WidgetationTheme.of(context);
    final pos = chooseChatBoxPosition(
      anchor: widget.draft.cursor,
      box: _boxSize,
      screen: media.size,
      insets: media.padding + const EdgeInsets.all(8),
    );
    final label = formatMultiNodeLabel(widget.draft.nodes);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: AnimatedBuilder(
        animation: _shakeCtrl,
        builder: (context, child) {
          final dx = math.sin(_shakeCtrl.value * math.pi * 6) *
              (1 - _shakeCtrl.value) *
              10;
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: SizedBox(
          width: _boxSize.width,
          child: Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(blurRadius: 8, offset: const Offset(0, 2), color: theme.shadow),
                BoxShadow(blurRadius: 16, offset: const Offset(0, 4), color: theme.shadow),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(label: label),
                const SizedBox(height: 8),
                _TextInput(
                  controller: _ctrl,
                  focusNode: _focus,
                  onSubmitted: (_) => _commit(),
                ),
                const SizedBox(height: 8),
                _Footer(
                  showDelete: widget.draft.isEditing,
                  primaryLabel: widget.draft.isEditing ? 'Save' : 'Add',
                  onCancel: _cancel,
                  onPrimary: _commit,
                  onDelete: _delete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String label;
  const _Header({required this.label});

  @override
  Widget build(BuildContext context) {
    final muted = WidgetationTheme.of(context).onSurfaceMuted;
    return Row(
      children: [
        Text(
          '›',
          style: TextStyle(
            color: muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  const _TextInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.accent, width: 1.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.text.isNotEmpty) return const SizedBox.shrink();
              return Text(
                'What should change?',
                style: TextStyle(color: theme.onSurfaceMuted, fontSize: 14),
                textDirection: TextDirection.ltr,
              );
            },
          ),
          EditableText(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(color: theme.onSurface, fontSize: 14),
            cursorColor: theme.onSurface,
            backgroundCursorColor: theme.onSurfaceMuted,
            textAlign: TextAlign.start,
            maxLines: 1,
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool showDelete;
  final String primaryLabel;
  final VoidCallback onCancel;
  final VoidCallback onPrimary;
  final VoidCallback onDelete;

  const _Footer({
    required this.showDelete,
    required this.primaryLabel,
    required this.onCancel,
    required this.onPrimary,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return Row(
      children: [
        if (showDelete)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDelete,
            child: SizedBox(
              width: 26,
              height: 26,
              child: CustomPaint(
                painter: ToolbarIconPainter(
                  icon: ToolbarIcon.trash,
                  color: theme.onSurfaceMuted,
                  strokeWidth: 1.6,
                ),
              ),
            ),
          ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onCancel,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.onSurfaceMuted, fontSize: 13, fontWeight: FontWeight.w500),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPrimary,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              primaryLabel,
              style: TextStyle(
                color: theme.onAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ],
    );
  }
}