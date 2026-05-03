import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../state/edits_store.dart';
import '../state/widgetation_store.dart';
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
  static const Size _boxSize = Size(360, 168);

  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.draft.text);
    _focus = FocusNode();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
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
    _ctrl.dispose();
    _focus.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _commit() => context.read<EditsStore>().commitDraft();
  void _cancel() => context.read<EditsStore>().cancelDraft();
  void _delete() {
    final id = widget.draft.editingId;
    if (id != null) context.read<EditsStore>().delete(id);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final pos = chooseChatBoxPosition(
      anchor: widget.draft.cursor,
      box: _boxSize,
      screen: media.size,
      insets: media.padding + const EdgeInsets.all(8),
    );
    final node = widget.draft.nodes.first;
    final label = formatNodeLabel(node);

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
          height: _boxSize.height,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x33000000)),
                BoxShadow(blurRadius: 16, offset: Offset(0, 4), color: Color(0x1A000000)),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(label: label),
                const SizedBox(height: 10),
                Expanded(
                  child: _TextInput(
                    controller: _ctrl,
                    focusNode: _focus,
                    onChanged: (v) =>
                        context.read<EditsStore>().updateDraftText(v),
                    onSubmitted: (_) => _commit(),
                  ),
                ),
                const SizedBox(height: 10),
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
    return Row(
      children: [
        const Text(
          '›',
          style: TextStyle(
            color: Color(0xFFB3B3B3),
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
            style: const TextStyle(
              color: Color(0xFFB3B3B3),
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
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _TextInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0091EA), width: 1.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.text.isNotEmpty) return const SizedBox.shrink();
              return const Text(
                'What should change?',
                style: TextStyle(color: Color(0xFF777777), fontSize: 14),
                textDirection: TextDirection.ltr,
              );
            },
          ),
          EditableText(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
            cursorColor: const Color(0xFFFFFFFF),
            backgroundCursorColor: const Color(0xFF555555),
            textAlign: TextAlign.start,
            maxLines: 1,
            onChanged: onChanged,
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
    return Row(
      children: [
        if (showDelete)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDelete,
            child: SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(
                painter: ToolbarIconPainter(
                  icon: ToolbarIcon.trash,
                  color: const Color(0xFFB3B3B3),
                  strokeWidth: 1.6,
                ),
              ),
            ),
          ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onCancel,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 14, fontWeight: FontWeight.w500),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPrimary,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0091EA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              primaryLabel,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
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