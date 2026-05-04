import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../tree_node.dart';
import '../state/edits_store.dart';
import '../state/selection_store.dart';
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

class _EditChatBoxState extends State<EditChatBox> with TickerProviderStateMixin {
  static const Size _collapsedSize = Size(270, 116);
  static const double _styleLineHeight = 16;
  static const double _stylesBlockPadV = 10;
  static const double _stylesBlockGap = 8;

  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  late final AnimationController _shakeCtrl;

  EditsStore? _store;
  SelectionStore? _selection;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.draft.text);
    _focus = FocusNode(onKeyEvent: _handleKey);
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _ctrl.addListener(_publishHasText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = context.read<EditsStore>();
    _selection = context.read<SelectionStore>();
    _publishHasText();
  }

  @override
  void didUpdateWidget(covariant EditChatBox old) {
    super.didUpdateWidget(old);
    if (old.draft.shakeNonce != widget.draft.shakeNonce) {
      _shakeCtrl.forward(from: 0);
    }
    // Keep controller text in sync on identity swap (e.g. editing flips).
    if (old.draft.editingId != widget.draft.editingId && _ctrl.text != widget.draft.text) {
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

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.enter &&
        event.logicalKey != LogicalKeyboardKey.numpadEnter) {
      return KeyEventResult.ignored;
    }
    if (HardwareKeyboard.instance.isShiftPressed) return KeyEventResult.ignored;
    _commit();
    return KeyEventResult.handled;
  }

  void _commit() {
    _store?.commitDraft(_ctrl.text);
    _selection?.clear();
  }

  void _cancel() {
    _store?.cancelDraft();
    _selection?.clear();
  }

  void _delete() {
    final id = widget.draft.editingId;
    if (id != null) _store?.delete(id);
  }

  void _toggleExpanded() {
    final node = widget.draft.nodes.isNotEmpty ? widget.draft.nodes.first : null;
    if (node == null || node.widgetProperties.isEmpty) return;
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = WidgetationTheme.of(context);
    final node = widget.draft.nodes.isNotEmpty ? widget.draft.nodes.first : null;
    final hasProps = node != null && node.widgetProperties.isNotEmpty;
    final propsCount = node?.widgetProperties.length ?? 0;

    // Estimated extra height when the styles block is expanded — used for
    // position calculation so the box still fits onscreen after expanding.
    final expandedExtra = _expanded
        ? _stylesBlockPadV * 2 + _styleLineHeight * propsCount + _stylesBlockGap
        : 0;
    final boxSize = Size(_collapsedSize.width, _collapsedSize.height + expandedExtra);

    final pos = chooseChatBoxPosition(
      anchor: widget.draft.cursor,
      box: boxSize,
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
          final dx = math.sin(_shakeCtrl.value * math.pi * 6) * (1 - _shakeCtrl.value) * 10;
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: SizedBox(
          width: _collapsedSize.width,
          child: Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(blurRadius: 8, offset: const Offset(0, 2), color: theme.shadow),
                BoxShadow(blurRadius: 16, offset: const Offset(0, 4), color: theme.shadow),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  label: label,
                  expanded: _expanded,
                  toggleable: hasProps,
                  onToggle: _toggleExpanded,
                ),
                if (_expanded && node != null) ...[
                  const SizedBox(height: _stylesBlockGap),
                  _StylesBlock(node: node),
                ],
                const SizedBox(height: 8),
                _TextInput(controller: _ctrl, focusNode: _focus, onSubmitted: (_) => _commit()),
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
  final bool expanded;
  final bool toggleable;
  final VoidCallback onToggle;

  const _Header({
    required this.label,
    required this.expanded,
    required this.toggleable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final muted = WidgetationTheme.of(context).onSurfaceMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggleable ? onToggle : null,
      child: Row(
        children: [
          AnimatedRotation(
            turns: expanded ? 0.25 : 0,
            duration: const Duration(milliseconds: 140),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CustomPaint(
                painter: ToolbarIconPainter(
                  icon: ToolbarIcon.chevronRight,
                  color: muted,
                  strokeWidth: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w400),
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}

class _StylesBlock extends StatelessWidget {
  final TreeNode node;
  const _StylesBlock({required this.node});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    final entries = node.widgetProperties.entries
        .where((e) => e.key != 'inherit')
        .toList(growable: false);
    final keyColor = theme.brightness == Brightness.dark
        ? const Color(0xFFC084FC)
        : const Color(0xFF7C3AED);
    final valueColor = theme.onSurfaceMuted;
    final bg = theme.brightness == Brightness.dark
        ? const Color(0xFF0E0E0E)
        : const Color(0xFFEFEFF1);

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${e.key}: ',
                      style: TextStyle(color: keyColor),
                    ),
                    TextSpan(
                      text: e.value,
                      style: TextStyle(color: valueColor),
                    ),
                    TextSpan(
                      text: ';',
                      style: TextStyle(color: valueColor),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontFamilyFallback: <String>['Menlo', 'Consolas', 'Courier'],
                  fontSize: 11,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  const _TextInput({required this.controller, required this.focusNode, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.accent, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 150, minHeight: 40),
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.text.isNotEmpty) return const SizedBox.shrink();
                return Text(
                  'What should change?',
                  style: TextStyle(
                    color: theme.onSurfaceMuted.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textDirection: TextDirection.ltr,
                );
              },
            ),
            EditableText(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(color: theme.onSurface, fontSize: 12),
              cursorColor: theme.onSurface,
              backgroundCursorColor: theme.onSurfaceMuted,
              textAlign: TextAlign.start,
              maxLines: null,
              onSubmitted: onSubmitted,
            ),
          ],
        ),
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
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDelete,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(
                  painter: ToolbarIconPainter(
                    icon: ToolbarIcon.trash,
                    color: theme.onSurfaceMuted,
                    strokeWidth: 1.2,
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCancel,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.onSurfaceMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
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
                style: TextStyle(color: theme.onAccent, fontSize: 11, fontWeight: FontWeight.w600),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
