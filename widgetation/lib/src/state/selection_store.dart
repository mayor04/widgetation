import 'package:flutter/foundation.dart';

import '../protocol/tree_node.dart' show TreeNode;
import 'widgetation_store.dart';

@immutable
class SelectionState {
  final List<TreeNode> nodes;
  final TreeNode? active;

  const SelectionState({this.nodes = const [], this.active});

  static const empty = SelectionState();

  bool get hasSelection => nodes.isNotEmpty;

  TreeNode? get primary => active ?? (nodes.isEmpty ? null : nodes.first);
}

class SelectionStore extends WidgetationStore<SelectionState> {
  SelectionStore() : super(SelectionState.empty);

  /// Replace the selection with a single node. Pass `null` to clear.
  void select(TreeNode? node) {
    emit(node == null
        ? SelectionState.empty
        : SelectionState(nodes: [node], active: node));
  }

  /// Add to the selection (multi-select; future use). No-op if [node] is
  /// already selected. The added node becomes [SelectionState.active].
  void add(TreeNode node) {
    if (value.nodes.contains(node)) return;
    emit(SelectionState(nodes: [...value.nodes, node], active: node));
  }

  /// Toggle membership. After removal, [SelectionState.active] falls back to
  /// the last remaining node (or null if the list is empty).
  void toggle(TreeNode node) {
    final nodes = value.nodes;
    if (nodes.contains(node)) {
      final next = nodes.where((n) => n != node).toList(growable: false);
      emit(SelectionState(
        nodes: next,
        active: next.isEmpty ? null : next.last,
      ));
    } else {
      emit(SelectionState(nodes: [...nodes, node], active: node));
    }
  }

  void clear() => emit(SelectionState.empty);
}
