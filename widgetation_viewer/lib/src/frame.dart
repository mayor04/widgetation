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
    return InspectorFrame(
      timestamp: (json['timestamp'] as num).toInt(),
      devicePixelRatio: (json['devicePixelRatio'] as num).toDouble(),
      logicalSize: Size(
        (size['w'] as num).toDouble(),
        (size['h'] as num).toDouble(),
      ),
      png: base64Decode(json['screenshot'] as String),
      tree: treeJson.map(TreeNode.fromJson).toList(),
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
  });

  bool contains(double px, double py) =>
      w > 0 && h > 0 && px >= x && py >= y && px <= x + w && py <= y + h;

  double get area => w * h;

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    final children = (json['children'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(TreeNode.fromJson)
        .toList();
    return TreeNode(
      type: json['type'] as String,
      depth: (json['depth'] as num).toInt(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      w: (json['w'] as num).toDouble(),
      h: (json['h'] as num).toDouble(),
      props: (json['props'] as List? ?? const []).cast<String>(),
      key: json['key'] as String?,
      children: children,
    );
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
