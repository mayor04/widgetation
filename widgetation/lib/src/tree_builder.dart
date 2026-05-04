import 'package:flutter/widgets.dart';

import 'tree_node.dart';

/// True when [file] points at code we don't consider user-owned: the
/// Flutter SDK itself or any third-party package resolved through the
/// pub cache (e.g. `file:///.../.pub-cache/hosted/pub.dev/forui-0.19.0/...`).
/// A null [file] means creation-location data is unavailable, which we
/// treat as external so unannotated nodes don't masquerade as user widgets.
bool isExternalWidgetFile(String? file) {
  if (file == null) return true;
  return file.startsWith('package:flutter/') ||
      file.contains('/packages/flutter/') ||
      file.contains('/.pub-cache/') ||
      file.contains('/pub-cache/');
}

/// Walks an [Element] tree and produces typed [TreeNode]s.
///
/// Each node carries its runtime type, depth, global rect (logical pixels),
/// a small map of diagnostic property summaries, and — when available —
/// creation-location metadata.
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

  /// Describe a single element (no children walked, no ancestor lookup).
  TreeNode describeOnly(Element element, int depth) =>
      _describe(element, depth, const <TreeNode>[]);

  /// Describe a single element and overlay ancestry metadata: the nearest
  /// public, non-flutter ancestor's widget type name plus an outermost-first
  /// list of up to 4 type names ending with this element's own type. Used by
  /// [WidgetPicker] when reporting the picked node so an LLM consumer can
  /// place it in context without re-walking.
  TreeNode describeWithAncestry(Element element, int depth) {
    final base = _describe(element, depth, const <TreeNode>[]);

    final ancestorTypes = <String>[]; // closest first; reversed at the end
    String? nearest;

    element.visitAncestorElements((ancestor) {
      final widget = ancestor.widget;
      final typeName = widget.runtimeType.toString();

      if (ancestorTypes.length < 3) {
        ancestorTypes.add(typeName);
      }

      if (nearest == null) {
        final file = _creationFile(widget);
        if (!isExternalWidgetFile(file)) {
          nearest = typeName;
        }
      }

      return ancestorTypes.length < 3 || nearest == null;
    });

    final ancestors = <String>[
      ...ancestorTypes.reversed,
      base.type,
    ];

    return base.copyWith(nearestWidget: nearest, ancestors: ancestors);
  }

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
    final extras = _delegate.additionalNodeProperties(
      widget.toDiagnosticsNode(),
      fullDetails: true,
    );
    final loc = extras['creationLocation'] as Map<Object?, Object?>?;
    if (loc != null && loc['file'] is String) {
      file = loc['file'] as String;
      if (loc['line'] is int) line = loc['line'] as int;
    }

    return TreeNode(
      type: widget.runtimeType.toString(),
      depth: depth,
      rect: rect,
      widgetProperties: _propertiesOf(widget),
      key: widget.key?.toString(),
      file: file,
      line: line,
      children: children,
    );
  }

  String? _creationFile(Widget widget) {
    final extras = _delegate.additionalNodeProperties(
      widget.toDiagnosticsNode(),
      fullDetails: true,
    );
    final loc = extras['creationLocation'] as Map<Object?, Object?>?;
    return loc?['file'] as String?;
  }

  /// Best-effort collection of diagnostic properties as a name → value map.
  /// Capped at 16 entries; later duplicates of the same name are ignored.
  static Map<String, String> _propertiesOf(Widget widget) {
    final node = widget.toDiagnosticsNode();
    final props = node.getProperties();
    final result = <String, String>{};
    for (final p in props) {
      if (p.level == DiagnosticLevel.hidden) continue;
      if (!_isInteresting(p)) continue;
      final name = p.name;
      if (name == null || name.isEmpty) continue;
      if (result.containsKey(name)) continue;
      result[name] = p.toDescription();
      if (result.length >= 16) break;
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
