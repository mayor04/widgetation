import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../protocol/tree_node.dart' show TreeNode;
import 'widgetation_store.dart';

/// Committed-edits slice of [EditsState]. Exposed as a separate listenable
/// so the bubbles list rebuilds only when the list (or hidden flag) actually
/// changes — not on every draft mutation.
typedef EditsListSlice = ({List<Edit> edits, bool hidden});

/// A committed edit annotation: the user typed something against one or
/// more widget nodes. Rendered as a numbered bubble at [cursor]; tapping
/// the bubble re-opens the chat box for editing.
@immutable
class Edit {
  final String id;
  final int index;
  final Offset cursor;
  final Rect? selectRect;
  final List<TreeNode> nodes;
  final String text;
  final List<String?> files;
  final List<String>? ancestors;
  final DateTime createdAt;

  const Edit({
    required this.id,
    required this.index,
    required this.cursor,
    required this.nodes,
    required this.text,
    required this.files,
    required this.createdAt,
    this.selectRect,
    this.ancestors,
  });

  Edit copyWith({String? text}) => Edit(
        id: id,
        index: index,
        cursor: cursor,
        selectRect: selectRect,
        nodes: nodes,
        text: text ?? this.text,
        files: files,
        ancestors: ancestors,
        createdAt: createdAt,
      );
}

/// Live state of the chat box. Either a brand-new draft ([editingId] null)
/// or an in-place edit of an existing [Edit].
@immutable
class EditDraft {
  final String? editingId;
  final Offset cursor;
  final Rect? selectRect;
  final List<TreeNode> nodes;
  final String text;
  final List<String?> files;
  final List<String>? ancestors;

  /// Increments to nudge a shake animation in the chat box (e.g. when the
  /// user taps another widget while the draft is open). Listeners diff on
  /// this to trigger a one-shot animation.
  final int shakeNonce;

  const EditDraft({
    required this.cursor,
    required this.nodes,
    required this.text,
    required this.files,
    this.editingId,
    this.selectRect,
    this.ancestors,
    this.shakeNonce = 0,
  });

  bool get isEditing => editingId != null;

  EditDraft copyWith({String? text, int? shakeNonce}) => EditDraft(
        editingId: editingId,
        cursor: cursor,
        selectRect: selectRect,
        nodes: nodes,
        text: text ?? this.text,
        files: files,
        ancestors: ancestors,
        shakeNonce: shakeNonce ?? this.shakeNonce,
      );
}

@immutable
class EditsState {
  final List<Edit> edits;
  final EditDraft? draft;
  final bool hidden;

  const EditsState({this.edits = const [], this.draft, this.hidden = false});

  static const empty = EditsState();

  bool get hasOpenDraft => draft != null;
}

class EditsStore extends WidgetationStore<EditsState> {
  EditsStore() : super(EditsState.empty);

  int _idCounter = 0;

  final ValueNotifier<EditsListSlice> _list = ValueNotifier(
    (edits: const <Edit>[], hidden: false),
  );
  final ValueNotifier<EditDraft?> _draft = ValueNotifier(null);
  final ValueNotifier<bool> _hasDraftText = ValueNotifier(false);

  /// Committed edits + hidden flag. Subscribe via [ValueListenableBuilder]
  /// to rebuild only when the list or its visibility actually changes —
  /// keystrokes in an open chat box do not propagate here.
  ValueListenable<EditsListSlice> get list => _list;

  /// Active draft (or null when no chat box is open). Fires on
  /// begin/cancel/commit/shake; the in-flight text is owned locally by
  /// the chat box's [TextEditingController] and is not echoed here.
  ValueListenable<EditDraft?> get draft => _draft;

  /// Whether the open draft has any non-whitespace text. Updated by the
  /// chat box from its controller; consumed by the host gesture layer to
  /// decide between nudge and re-anchor when the user taps elsewhere.
  ValueListenable<bool> get hasDraftText => _hasDraftText;

  // ignore: use_setters_to_change_properties
  void setHasDraftText(bool v) => _hasDraftText.value = v;

  @override
  void emit(EditsState newState) {
    _list.value = (edits: newState.edits, hidden: newState.hidden);
    _draft.value = newState.draft;
    super.emit(newState);
  }

  @override
  void dispose() {
    _list.dispose();
    _draft.dispose();
    _hasDraftText.dispose();
    super.dispose();
  }

  /// Open a fresh draft anchored at [cursor] for the given [node]. No-op
  /// if a draft is already open — caller should call [shake] instead.
  void beginCompose({required Offset cursor, required TreeNode node}) {
    if (value.draft != null) return;
    emit(EditsState(
      edits: value.edits,
      hidden: value.hidden,
      draft: EditDraft(
        cursor: cursor,
        nodes: [node],
        text: '',
        files: [node.file],
        ancestors: node.ancestors.isEmpty ? null : List.unmodifiable(node.ancestors),
      ),
    ));
  }

  /// Open a fresh draft for a multi-node marquee selection anchored at
  /// [cursor] (typically the drag-end position). [selectRect] is the union
  /// of all node rects, used as the post-commit selection visual.
  void beginComposeMulti({
    required Offset cursor,
    required List<TreeNode> nodes,
    required Rect selectRect,
  }) {
    if (value.draft != null) return;
    if (nodes.isEmpty) return;
    final first = nodes.first;
    emit(EditsState(
      edits: value.edits,
      hidden: value.hidden,
      draft: EditDraft(
        cursor: cursor,
        nodes: List.unmodifiable(nodes),
        text: '',
        files: [for (final n in nodes) n.file],
        selectRect: selectRect,
        ancestors: first.ancestors.isEmpty ? null : List.unmodifiable(first.ancestors),
      ),
    ));
  }

  /// Bump [EditDraft.shakeNonce] to trigger a shake animation. Used when
  /// the user taps another widget or the toolbar tries to clear while a
  /// draft is open — selection stays put, the chat box just nudges.
  void shake() {
    final d = value.draft;
    if (d == null) return;
    emit(EditsState(
      edits: value.edits,
      hidden: value.hidden,
      draft: d.copyWith(shakeNonce: d.shakeNonce + 1),
    ));
  }

  void cancelDraft() {
    if (value.draft == null) return;
    emit(EditsState(edits: value.edits, hidden: value.hidden));
  }

  /// Persist the current draft to the edits list. The chat box owns the
  /// in-flight text via its own [TextEditingController] and passes it in
  /// here on commit, so the store doesn't re-emit on every keystroke.
  /// New drafts append a new [Edit]; in-place edits replace the matching
  /// entry's text.
  void commitDraft(String rawText) {
    final d = value.draft;
    if (d == null) return;
    final text = rawText.trim();
    if (text.isEmpty) {
      cancelDraft();
      return;
    }
    if (d.isEditing) {
      final updated = value.edits
          .map((e) => e.id == d.editingId ? e.copyWith(text: text) : e)
          .toList(growable: false);
      emit(EditsState(edits: updated, hidden: value.hidden));
    } else {
      _idCounter += 1;
      final edit = Edit(
        id: 'edit-$_idCounter',
        index: value.edits.length + 1,
        cursor: d.cursor,
        selectRect: d.selectRect,
        nodes: d.nodes,
        text: text,
        files: d.files,
        ancestors: d.ancestors,
        createdAt: DateTime.now(),
      );
      emit(EditsState(edits: [...value.edits, edit], hidden: value.hidden));
    }
  }

  /// Re-open an existing edit's chat box. No-op if a draft is already open
  /// or the id is unknown.
  void editExisting(String id) {
    if (value.draft != null) return;
    final edit = value.edits.firstWhere(
      (e) => e.id == id,
      orElse: () => _missing,
    );
    if (identical(edit, _missing)) return;
    emit(EditsState(
      edits: value.edits,
      hidden: value.hidden,
      draft: EditDraft(
        editingId: edit.id,
        cursor: edit.cursor,
        selectRect: edit.selectRect,
        nodes: edit.nodes,
        text: edit.text,
        files: edit.files,
        ancestors: edit.ancestors,
      ),
    ));
  }

  /// Remove an edit. If a draft is currently editing the same id, it is
  /// dismissed at the same time. Index numbers of remaining edits are
  /// renumbered to stay contiguous.
  void delete(String id) {
    final remaining = <Edit>[];
    var renumber = 0;
    for (final e in value.edits) {
      if (e.id == id) continue;
      renumber += 1;
      remaining.add(Edit(
        id: e.id,
        index: renumber,
        cursor: e.cursor,
        selectRect: e.selectRect,
        nodes: e.nodes,
        text: e.text,
        files: e.files,
        ancestors: e.ancestors,
        createdAt: e.createdAt,
      ));
    }
    final dropDraft = value.draft?.editingId == id;
    emit(EditsState(
      edits: remaining,
      hidden: value.hidden,
      draft: dropDraft ? null : value.draft,
    ));
  }

  void clear() {
    if (value.edits.isEmpty && value.draft == null) return;
    emit(EditsState.empty);
  }

  void toggleHidden() {
    emit(EditsState(
      edits: value.edits,
      draft: value.draft,
      hidden: !value.hidden,
    ));
  }

  static final Edit _missing = Edit(
    id: '',
    index: -1,
    cursor: Offset.zero,
    nodes: const [],
    text: '',
    files: const [],
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
