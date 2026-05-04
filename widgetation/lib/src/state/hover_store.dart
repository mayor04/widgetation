import 'package:flutter/widgets.dart';

import '../tree_node.dart' show TreeNode;
import 'widgetation_store.dart';

@immutable
class HoverState {
  final TreeNode? node;
  final Offset? cursor;

  const HoverState({this.node, this.cursor});

  static const empty = HoverState();
}

class HoverStore extends WidgetationStore<HoverState> {
  HoverStore() : super(HoverState.empty);

  void set(TreeNode? node, Offset? cursor) =>
      emit(HoverState(node: node, cursor: cursor));

  void clear() => emit(HoverState.empty);
}
