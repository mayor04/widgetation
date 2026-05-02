import 'package:flutter/widgets.dart';

import 'protocol/tree_node.dart';
import 'tree_builder.dart';

/// Element-tree hit tester for on-device select mode.
///
/// Returns the deepest user widget whose paint rect contains [globalPos].
/// Uses [TreeBuilder.describeOnly] to produce the typed [TreeNode] so the
/// caller can read `type`, `rect`, `file`, `line`, etc. without inventing
/// a parallel data type.
class WidgetPicker {
  WidgetPicker({TreeBuilder? builder}) : _builder = builder ?? TreeBuilder();

  final TreeBuilder _builder;

  TreeNode? findAt(Element root, Offset globalPos) {
    TreeNode? best;
    int bestDepth = -1;

    void visit(Element element, int depth) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.attached && ro.hasSize) {
        final origin = ro.localToGlobal(Offset.zero);
        final size = ro.size;
        final inside = globalPos.dx >= origin.dx &&
            globalPos.dy >= origin.dy &&
            globalPos.dx <= origin.dx + size.width &&
            globalPos.dy <= origin.dy + size.height;
        if (!inside) return;
        final node = _builder.describeOnly(element, depth);
        if (node.isUserWidget && depth > bestDepth) {
          best = node;
          bestDepth = depth;
        }
      }
      element.visitChildren((c) => visit(c, depth + 1));
    }

    visit(root, 0);
    return best;
  }

  /// Deepest [Element] (any widget, user-defined or framework) whose render
  /// box contains [globalPos]. Used to find the nearest [Scrollable] for
  /// pan-forwarding in select mode.
  Element? elementAt(Element root, Offset globalPos) {
    Element? best;
    int bestDepth = -1;

    void visit(Element element, int depth) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.attached && ro.hasSize) {
        final origin = ro.localToGlobal(Offset.zero);
        final size = ro.size;
        final inside = globalPos.dx >= origin.dx &&
            globalPos.dy >= origin.dy &&
            globalPos.dx <= origin.dx + size.width &&
            globalPos.dy <= origin.dy + size.height;
        if (!inside) return;
        if (depth > bestDepth) {
          best = element;
          bestDepth = depth;
        }
      }
      element.visitChildren((c) => visit(c, depth + 1));
    }

    visit(root, 0);
    return best;
  }
}
