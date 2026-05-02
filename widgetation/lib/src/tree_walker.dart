import 'package:flutter/widgets.dart';

/// Walks the element tree rooted at [root] and produces a JSON-friendly
/// representation: each node carries its runtime type, depth, global rect
/// (in logical pixels), and a small set of diagnostic property summaries.
///
/// Subtrees whose render object is not a [RenderBox], lacks a size, or is
/// not attached are still emitted (so structure isn't lost) but report a
/// zero-area rect so the viewer's hit-testing skips them naturally.
List<Map<String, dynamic>> walkTree(Element root) {
  final out = <Map<String, dynamic>>[];
  // Reuse one delegate; we only call additionalNodeProperties on it, never
  // toJsonMap, so subtreeDepth/groupName are irrelevant.
  // InspectorSerializationDelegate is annotated @visibleForTesting but is
  // the only public surface that exposes creation-location data.
  // ignore: invalid_use_of_visible_for_testing_member
  final delegate = InspectorSerializationDelegate(
    service: WidgetInspectorService.instance,
    includeProperties: false,
    subtreeDepth: 0,
  );
  _visit(root, 0, out, delegate);
  return out;
}

void _visit(
  Element element,
  int depth,
  List<Map<String, dynamic>> out,
  // ignore: invalid_use_of_visible_for_testing_member
  InspectorSerializationDelegate delegate,
) {
  final node = _describe(element, depth, delegate);
  final children = <Map<String, dynamic>>[];
  element.visitChildren((child) {
    _visit(child, depth + 1, children, delegate);
  });
  node['children'] = children;
  out.add(node);
}

Map<String, dynamic> _describe(
  Element element,
  int depth,
  // ignore: invalid_use_of_visible_for_testing_member
  InspectorSerializationDelegate delegate,
) {
  final widget = element.widget;
  final renderObject = element.renderObject;

  double x = 0, y = 0, w = 0, h = 0;
  if (renderObject is RenderBox &&
      renderObject.attached &&
      renderObject.hasSize) {
    final size = renderObject.size;
    final offset = renderObject.localToGlobal(Offset.zero);
    x = offset.dx;
    y = offset.dy;
    w = size.width;
    h = size.height;
  }

  final result = <String, dynamic>{
    'type': widget.runtimeType.toString(),
    'depth': depth,
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'props': _propertiesOf(widget),
    'key': widget.key?.toString(),
  };

  // Creation location requires --track-widget-creation (debug builds get
  // this by default). When unavailable, fall back to a name heuristic.
  final extras = delegate.additionalNodeProperties(
    widget.toDiagnosticsNode(),
    fullDetails: true,
  );
  final loc = extras['creationLocation'] as Map<Object?, Object?>?;
  if (loc != null) {
    final file = loc['file'] as String?;
    final line = loc['line'];
    if (file != null) {
      result['file'] = file;
      if (line is int) result['line'] = line;
      result['isUserWidget'] = !file.startsWith('package:flutter/');
    }
  } else {
    result['isUserWidget'] = _looksLikeUserWidget(widget.runtimeType.toString());
  }

  return result;
}

/// Fallback when creation-location tracking is off: any private (`_Foo`)
/// type is assumed framework, everything else is treated as user code. Crude
/// but only ever over-reports user widgets.
bool _looksLikeUserWidget(String type) {
  final base = type.split('<').first;
  return !base.startsWith('_');
}

/// Best-effort collection of diagnostic properties as `name: value` strings.
/// Skips properties that don't have a value or are explicitly hidden.
List<String> _propertiesOf(Widget widget) {
  final node = widget.toDiagnosticsNode();
  final props = node.getProperties();
  final result = <String>[];
  for (final p in props) {
    if (p.level == DiagnosticLevel.hidden) continue;
    if (!p.isInteresting) continue;
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

extension on DiagnosticsNode {
  bool get isInteresting {
    final v = value;
    if (v == null) return false;
    if (v is bool && v == false && level != DiagnosticLevel.error) return false;
    return true;
  }
}
