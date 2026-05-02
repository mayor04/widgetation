import 'package:flutter/widgets.dart';

import 'protocol/tree_node.dart';

/// Walks an [Element] tree and produces typed [TreeNode]s.
///
/// Each node carries its runtime type, depth, global rect (logical pixels),
/// a small set of diagnostic property summaries, and — when available —
/// creation-location metadata used to flag user-defined widgets.
///
/// Subtrees whose render object is not a [RenderBox], lacks a size, or is
/// not attached are still emitted (so structure isn't lost) but report a
/// zero-area rect so the viewer's hit-testing skips them naturally.
class TreeBuilder {
  TreeBuilder()
    // InspectorSerializationDelegate is annotated @visibleForTesting but
    // is the only public surface that exposes creation-location data.
    // ignore: invalid_use_of_visible_for_testing_member
    : _delegate = InspectorSerializationDelegate(
        service: WidgetInspectorService.instance,
        includeProperties: false,
        subtreeDepth: 0,
      );

  // ignore: invalid_use_of_visible_for_testing_member
  final InspectorSerializationDelegate _delegate;

  List<TreeNode> walk(Element root) {
    final out = <TreeNode>[];
    _visit(root, 0, out);
    return out;
  }

  /// Describe a single element (no children walked). Used by [WidgetPicker]
  /// when we only need leaf info for the deepest hit, not a whole tree.
  TreeNode describeOnly(Element element, int depth) =>
      _describe(element, depth, const <TreeNode>[]);

  void _visit(Element element, int depth, List<TreeNode> out) {
    final children = <TreeNode>[];
    element.visitChildren((c) => _visit(c, depth + 1, children));
    out.add(_describe(element, depth, children));
  }

  TreeNode _describe(Element element, int depth, List<TreeNode> children) {
    final widget = element.widget;
    final renderObject = element.renderObject;

    var rect = Rect.zero;
    if (renderObject is RenderBox && renderObject.attached && renderObject.hasSize) {
      final size = renderObject.size;
      final offset = renderObject.localToGlobal(Offset.zero);
      rect = Rect(offset.dx, offset.dy, size.width, size.height);
    }

    String? file;
    int? line;
    bool isUserWidget;

    final extras = _delegate.additionalNodeProperties(
      widget.toDiagnosticsNode(),
      fullDetails: true,
    );
    final loc = extras['creationLocation'] as Map<Object?, Object?>?;
    if (loc != null && loc['file'] is String) {
      file = loc['file'] as String;
      if (loc['line'] is int) line = loc['line'] as int;
      isUserWidget = !file.startsWith('package:flutter/');
    } else {
      // Creation-location tracking is off; fall back to a name heuristic.
      // Private (`_Foo`) types are assumed framework, everything else user.
      isUserWidget = !widget.runtimeType.toString().split('<').first.startsWith('_');
    }

    return TreeNode(
      type: widget.runtimeType.toString(),
      depth: depth,
      rect: rect,
      props: _propertiesOf(widget),
      key: widget.key?.toString(),
      isUserWidget: isUserWidget,
      file: file,
      line: line,
      children: children,
    );
  }

  /// Best-effort collection of diagnostic properties as `name: value` strings.
  static List<String> _propertiesOf(Widget widget) {
    final node = widget.toDiagnosticsNode();
    final props = node.getProperties();
    final result = <String>[];
    for (final p in props) {
      if (p.level == DiagnosticLevel.hidden) continue;
      if (!_isInteresting(p)) continue;
      final name = p.name;
      final value = p.toDescription();
      if (name == null || name.isEmpty) {
        result.add(value);
      } else {
        result.add('$name: $value');
      }
      if (result.length >= 16) break; // cap payload size
    }
    return result;
  }

  static bool _isInteresting(DiagnosticsNode p) {
    final v = p.value;
    if (v == null) return false;
    if (v is bool && v == false && p.level != DiagnosticLevel.error) {
      return false;
    }
    return true;
  }
}
