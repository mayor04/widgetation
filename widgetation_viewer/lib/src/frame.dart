import 'dart:convert';
import 'dart:typed_data';

/// Single decoded frame received from the streamer.
class InspectorFrame {
  final int timestamp;
  final double devicePixelRatio;
  final Size logicalSize;
  final Uint8List png;
  final List<TreeNode> tree;

  InspectorFrame({
    required this.timestamp,
    required this.devicePixelRatio,
    required this.logicalSize,
    required this.png,
    required this.tree,
  });

  factory InspectorFrame.fromJson(Map<String, dynamic> json) {
    final size = json['screenSize'] as Map<String, dynamic>;
    final treeJson = (json['tree'] as List).cast<Map<String, dynamic>>();
    final tree = treeJson.map((j) => TreeNode.fromJson(j, null)).toList();
    return InspectorFrame(
      timestamp: (json['timestamp'] as num).toInt(),
      devicePixelRatio: (json['devicePixelRatio'] as num).toDouble(),
      logicalSize: Size(
        (size['w'] as num).toDouble(),
        (size['h'] as num).toDouble(),
      ),
      png: base64Decode(json['screenshot'] as String),
      tree: tree,
    );
  }
}

class Size {
  final double width;
  final double height;
  const Size(this.width, this.height);
}

/// One node in the streamed widget tree. Coordinates are in logical pixels.
class TreeNode {
  final String type;
  final int depth;
  final double x, y, w, h;
  final List<String> props;
  final String? key;
  final List<TreeNode> children;
  final bool isUserWidget;
  final String? file;
  final int? line;

  /// Parent is set during construction; null only for root nodes.
  TreeNode? parent;

  TreeNode({
    required this.type,
    required this.depth,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.props,
    required this.key,
    required this.children,
    required this.isUserWidget,
    this.file,
    this.line,
  });

  bool contains(double px, double py) =>
      w > 0 && h > 0 && px >= x && py >= y && px <= x + w && py <= y + h;

  double get area => w * h;

  /// Walks up the parent chain and returns the nearest ancestor (inclusive
  /// of `this`) whose widget is user-defined. Null if there is no such
  /// ancestor — e.g. the entire tree is framework widgets.
  TreeNode? get nearestUserAncestor {
    TreeNode? n = this;
    while (n != null) {
      if (n.isUserWidget) return n;
      n = n.parent;
    }
    return null;
  }

  /// Path from `this` up to (and including) the nearest user-widget ancestor,
  /// in display order: `[userAncestor, ..., this]`. If no user ancestor
  /// exists, returns just `[this]`.
  List<TreeNode> get pathFromUserAncestor {
    final stack = <TreeNode>[];
    TreeNode? n = this;
    while (n != null) {
      stack.add(n);
      if (n.isUserWidget && n != this) break;
      n = n.parent;
    }
    return stack.reversed.toList();
  }

  factory TreeNode.fromJson(Map<String, dynamic> json, TreeNode? parent) {
    final node = TreeNode(
      type: json['type'] as String,
      depth: (json['depth'] as num).toInt(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      w: (json['w'] as num).toDouble(),
      h: (json['h'] as num).toDouble(),
      props: (json['props'] as List? ?? const []).cast<String>(),
      key: json['key'] as String?,
      isUserWidget: json['isUserWidget'] as bool? ?? false,
      file: json['file'] as String?,
      line: (json['line'] as num?)?.toInt(),
      children: <TreeNode>[],
    );
    node.parent = parent;
    final childJson = (json['children'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    for (final j in childJson) {
      node.children.add(TreeNode.fromJson(j, node));
    }
    return node;
  }
}

/// Walks [roots] depth-first and returns the deepest, smallest-area node
/// whose rect contains the point.
TreeNode? hitTest(List<TreeNode> roots, double x, double y) {
  TreeNode? best;
  void visit(TreeNode n) {
    if (!n.contains(x, y)) {
      // Children are bounded by parent in normal Flutter layout; if the
      // parent doesn't contain the point we can prune. But because
      // overflowing renderers exist, still recurse.
    } else {
      if (best == null ||
          n.depth > best!.depth ||
          (n.depth == best!.depth && n.area < best!.area)) {
        best = n;
      }
    }
    for (final c in n.children) {
      visit(c);
    }
  }

  for (final r in roots) {
    visit(r);
  }
  return best;
}
