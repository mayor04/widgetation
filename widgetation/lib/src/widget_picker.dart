import 'package:flutter/widgets.dart';

import 'protocol/tree_node.dart' show TreeNode;
import 'tree_builder.dart';

/// Element-tree hit tester for on-device select mode.
///
/// Returns the deepest non-flutter widget whose paint rect contains
/// [globalPos], with `nearestWidget` and `ancestors` populated so the
/// caller has enough context to identify the selection in an LLM prompt.
class WidgetPicker {
  WidgetPicker({TreeBuilder? builder}) : _builder = builder ?? TreeBuilder();

  final TreeBuilder _builder;

  TreeNode? findAt(Element root, Offset globalPos) {
    Element? bestElement;
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
        // Cheap filter using the same flutter-file test the builder uses
        // for ancestry. We still describe the node only after it wins,
        // so non-flutter screening doesn't run on every passed-over
        // framework element.
        if (depth > bestDepth) {
          final node = _builder.describeOnly(element, depth);
          if (!isFlutterWidgetFile(node.file)) {
            bestElement = element;
            bestDepth = depth;
          }
        }
      }
      element.visitChildren((c) => visit(c, depth + 1));
    }

    visit(root, 0);
    final el = bestElement;
    if (el == null) return null;
    return _builder.describeWithAncestry(el, bestDepth);
  }

  /// Every non-flutter user widget whose paint rect is at least
  /// [_kCoverageThreshold] covered by [marquee], filtered to top-most
  /// ancestors only (any candidate that has another candidate as an
  /// element-tree ancestor is dropped).
  ///
  /// The coverage gate is what keeps screen-spanning wrappers (the
  /// app's root user widget, page scaffolds) out of the result: their
  /// rect intersects every marquee but only a tiny fraction is covered,
  /// so they fail the threshold while the things actually inside the
  /// dragged region pass.
  List<TreeNode> findAllIn(Element root, Rect marquee) {
    final candidates = <_Candidate>[];

    void visit(Element element, int depth) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.attached && ro.hasSize) {
        final origin = ro.localToGlobal(Offset.zero);
        final size = ro.size;
        final box = Rect.fromLTWH(origin.dx, origin.dy, size.width, size.height);
        if (!box.overlaps(marquee)) {
          // RenderBox children paint within the parent's bounds; if we
          // don't overlap the marquee, descendants can't either.
          return;
        }
        if (_coverage(box, marquee) >= _kCoverageThreshold) {
          final described = _builder.describeOnly(element, depth);
          if (!isFlutterWidgetFile(described.file)) {
            candidates.add(_Candidate(element, depth));
          }
        }
      }
      element.visitChildren((c) => visit(c, depth + 1));
    }

    visit(root, 0);
    if (candidates.isEmpty) return const [];

    final set = {for (final c in candidates) c.element};
    final survivors = <_Candidate>[];
    for (final c in candidates) {
      var hasAncestorInSet = false;
      c.element.visitAncestorElements((a) {
        if (set.contains(a)) {
          hasAncestorInSet = true;
          return false;
        }
        return true;
      });
      if (!hasAncestorInSet) survivors.add(c);
    }

    return [
      for (final s in survivors) _builder.describeWithAncestry(s.element, s.depth),
    ];
  }
}

/// Minimum fraction of a candidate's own area that must lie inside the
/// marquee for it to qualify. Picked empirically: high enough to reject
/// page-scaffold wrappers when you drag a small box, low enough to
/// tolerate a marquee that clips the edges of a target.
const double _kCoverageThreshold = 0.6;

double _coverage(Rect candidate, Rect marquee) {
  if (candidate.width <= 0 || candidate.height <= 0) return 0;
  final hit = candidate.intersect(marquee);
  if (hit.width <= 0 || hit.height <= 0) return 0;
  return (hit.width * hit.height) / (candidate.width * candidate.height);
}

class _Candidate {
  final Element element;
  final int depth;
  _Candidate(this.element, this.depth);
}
