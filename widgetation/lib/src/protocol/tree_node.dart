/// Typed model for a node in the streamed widget tree.
///
/// This file is the wire-format source of truth on the streamer side. The
/// viewer keeps its own decoded copy; both ends must agree on the keys
/// produced by [toJson].
class Rect {
  final double x, y, w, h;
  const Rect(this.x, this.y, this.w, this.h);
  static const Rect zero = Rect(0, 0, 0, 0);
}

class TreeNode {
  final String type;
  final int depth;
  final Rect rect;
  final List<String> props;
  final String? key;
  final bool isUserWidget;
  final String? file;
  final int? line;
  final List<TreeNode> children;

  const TreeNode({
    required this.type,
    required this.depth,
    required this.rect,
    required this.props,
    required this.key,
    required this.isUserWidget,
    required this.children,
    this.file,
    this.line,
  });

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        'depth': depth,
        'x': rect.x,
        'y': rect.y,
        'w': rect.w,
        'h': rect.h,
        'props': props,
        if (key != null) 'key': key,
        'isUserWidget': isUserWidget,
        if (file != null) 'file': file,
        if (line != null) 'line': line,
        'children': children.map((c) => c.toJson()).toList(),
      };
}
