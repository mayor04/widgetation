/// Typed model for a node picked out of the live element tree.
class Rect {
  final double x, y, w, h;
  const Rect(this.x, this.y, this.w, this.h);
  static const Rect zero = Rect(0, 0, 0, 0);
}

class TreeNode {
  final String type;
  final int depth;
  final Rect rect;
  final Map<String, String> widgetProperties;
  final String? key;
  final String? file;
  final int? line;

  /// Type name of the closest non-flutter ancestor of this node, walking
  /// upward through the element tree. Null when no non-flutter ancestor
  /// exists, or when ancestry wasn't computed (only the picker-selected
  /// node carries this).
  final String? nearestWidget;

  /// Up to 4 widget type names along the ancestor chain, outermost-first,
  /// with this node's own type as the last entry. Empty when not
  /// computed (only the picker-selected node carries this).
  final List<String> ancestors;

  final List<TreeNode> children;

  const TreeNode({
    required this.type,
    required this.depth,
    required this.rect,
    required this.widgetProperties,
    required this.key,
    required this.children,
    this.file,
    this.line,
    this.nearestWidget,
    this.ancestors = const <String>[],
  });

  TreeNode copyWith({
    String? nearestWidget,
    List<String>? ancestors,
  }) =>
      TreeNode(
        type: type,
        depth: depth,
        rect: rect,
        widgetProperties: widgetProperties,
        key: key,
        children: children,
        file: file,
        line: line,
        nearestWidget: nearestWidget ?? this.nearestWidget,
        ancestors: ancestors ?? this.ancestors,
      );
}
