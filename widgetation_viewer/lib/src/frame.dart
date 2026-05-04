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
  final Map<String, String> widgetProperties;
  final String? key;
  final List<TreeNode> children;
  final String? file;
  final int? line;

  /// Set when this node was the picker's selection target.
  final String? nearestWidget;

  /// Set when this node was the picker's selection target. Outermost-first,
  /// last entry is this node's own type.
  final List<String> ancestors;

  /// Parent is set during construction; null only for root nodes.
  TreeNode? parent;

  TreeNode({
    required this.type,
    required this.depth,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.widgetProperties,
    required this.key,
    required this.children,
    required this.nearestWidget,
    required this.ancestors,
    this.file,
    this.line,
  });

  bool contains(double px, double py) =>
      w > 0 && h > 0 && px >= x && py >= y && px <= x + w && py <= y + h;

  double get area => w * h;

  /// True when this node's creation-location points at framework or
  /// third-party code (Flutter SDK or pub-cache), or is unknown. Mirrors
  /// the streamer's `isExternalWidgetFile` check; kept in sync there.
  bool get isFlutterWidget {
    final f = file;
    if (f == null) return true;
    return f.startsWith('package:flutter/') ||
        f.contains('/packages/flutter/') ||
        f.contains('/.pub-cache/') ||
        f.contains('/pub-cache/');
  }

  factory TreeNode.fromJson(Map<String, dynamic> json, TreeNode? parent) {
    final propsJson = json['widgetProperties'] as Map<String, dynamic>?;
    final ancestorsJson = json['ancestors'] as List?;
    final node = TreeNode(
      type: json['type'] as String,
      depth: (json['depth'] as num).toInt(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      w: (json['w'] as num).toDouble(),
      h: (json['h'] as num).toDouble(),
      widgetProperties: propsJson == null
          ? const <String, String>{}
          : propsJson.map((k, v) => MapEntry(k, v.toString())),
      key: json['key'] as String?,
      file: json['file'] as String?,
      line: (json['line'] as num?)?.toInt(),
      nearestWidget: json['nearestWidget'] as String?,
      ancestors: ancestorsJson == null
          ? const <String>[]
          : ancestorsJson.cast<String>(),
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
