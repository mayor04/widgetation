import 'package:flutter/rendering.dart'
    show RenderFollowerLayer, RenderTransform;
import 'package:flutter/widgets.dart';

import 'tree_node.dart' show TreeNode;
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
    final hits = <_Candidate>[];

    void visit(Element element, int depth) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.attached && ro.hasSize) {
        final origin = ro.localToGlobal(Offset.zero);
        final size = ro.size;
        final inside =
            globalPos.dx >= origin.dx &&
            globalPos.dy >= origin.dy &&
            globalPos.dx <= origin.dx + size.width &&
            globalPos.dy <= origin.dy + size.height;
        if (inside) {
          hits.add(_Candidate(element, depth));
        } else if (!_descendantsMayEscape(ro)) {
          // Pruning: most renderers paint descendants within their own
          // layout rect, so a miss on the parent rules out children. The
          // exceptions (CompositedTransformFollower, Transform) project
          // descendants elsewhere via a layer transform — descend anyway.
          return;
        }
      }
      element.visitChildren((c) => visit(c, depth + 1));
    }

    visit(root, 0);
    if (hits.isEmpty) return null;

    // Iterate in reverse visit order so the topmost-painted widget wins:
    // DFS preorder matches Flutter's paint order (parents before children,
    // earlier siblings before later), so the last hit is what the user
    // sees on top. Sorting by element-tree depth instead would pick a
    // deeply-nested widget on a page underneath an open dialog/overlay.
    // describeOnly is the dominant cost; deferring it here means we only
    // pay for hits we actually evaluate.
    for (var i = hits.length - 1; i >= 0; i--) {
      final h = hits[i];
      final node = _builder.describeOnly(h.element, h.depth);
      if (!isExternalWidgetFile(node.file)) {
        return _builder.describeWithAncestry(h.element, h.depth);
      }
    }
    return null;
  }

  /// Deepest [Scrollable] whose paint rect contains [globalPos], or
  /// null when the point is over no scrollable. Used by select mode to
  /// forward mouse-wheel and trackpad pan-zoom events to the underlying
  /// app while the inspector absorbs raw pointer input.
  ScrollableState? findScrollableAt(Element root, Offset globalPos) {
    ScrollableState? deepest;
    void visit(Element element) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.attached && ro.hasSize) {
        final origin = ro.localToGlobal(Offset.zero);
        final size = ro.size;
        final inside =
            globalPos.dx >= origin.dx &&
            globalPos.dy >= origin.dy &&
            globalPos.dx <= origin.dx + size.width &&
            globalPos.dy <= origin.dy + size.height;
        if (!inside && !_descendantsMayEscape(ro)) return;
      }
      if (element.widget is Scrollable && element is StatefulElement) {
        final state = element.state;
        if (state is ScrollableState) deepest = state;
      }
      element.visitChildren(visit);
    }

    visit(root);
    return deepest;
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
    final survivors = <_Candidate>[];

    void visit(Element element, int depth) {
      final ro = element.renderObject;
      if (ro is RenderBox && ro.attached && ro.hasSize) {
        final origin = ro.localToGlobal(Offset.zero);
        final size = ro.size;
        final box = Rect.fromLTWH(
          origin.dx,
          origin.dy,
          size.width,
          size.height,
        );
        if (box.overlaps(marquee)) {
          if (_coverage(box, marquee) >= _kCoverageThreshold) {
            final described = _builder.describeOnly(element, depth);
            if (!isExternalWidgetFile(described.file)) {
              survivors.add(_Candidate(element, depth));
              // Any non-flutter descendant of this element would be dropped
              // by the topmost-ancestor rule anyway, so don't pay to walk
              // or describe them.
              return;
            }
          }
        } else if (!_descendantsMayEscape(ro)) {
          // See findAt: prune on a miss except for layer/transform
          // renderers whose descendants paint elsewhere.
          return;
        }
      }
      element.visitChildren((c) => visit(c, depth + 1));
    }

    visit(root, 0);
    if (survivors.isEmpty) return const [];

    return [
      for (final s in survivors)
        _builder.describeWithAncestry(s.element, s.depth),
    ];
  }
}

/// True when this render object can paint its descendants outside its own
/// layout rect via a layer transform — i.e. it's not safe to prune the
/// subtree from a hit-test just because the parent rect missed.
///
/// Currently covers `CompositedTransformFollower` (anchored popovers /
/// menus) and `Transform` (rotated / translated content). Stack with
/// clipBehavior == Clip.none also overflows, but we don't special-case it
/// here — overflowing children inside an unclipped Stack are uncommon
/// outside of animations, and treating Stack as escapable would defeat
/// most of the prune optimization.
bool _descendantsMayEscape(RenderBox ro) =>
    ro is RenderFollowerLayer || ro is RenderTransform;

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
