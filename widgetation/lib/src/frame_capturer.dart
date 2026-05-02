import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'protocol/frame.dart';
import 'tree_builder.dart';

/// Produces a [Frame] from the [RenderRepaintBoundary] reachable through
/// [boundaryKey]: the boundary is rasterised to PNG, the element subtree is
/// walked with [treeBuilder], and the two are bundled together with sizing
/// metadata.
///
/// Returns `null` on transient failure — boundary not attached, no size,
/// rasterisation aborted — so the caller can simply skip a tick instead of
/// surfacing an error.
class FrameCapturer {
  FrameCapturer({
    required this.boundaryKey,
    required this.treeBuilder,
    this.pixelRatioOverride,
  });

  final GlobalKey boundaryKey;
  final TreeBuilder treeBuilder;
  final double? pixelRatioOverride;

  Future<Frame?> captureOnce() async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) return null;
    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;
    if (!renderObject.attached || !renderObject.hasSize) return null;

    final view = View.maybeOf(ctx);
    final dpr = pixelRatioOverride ?? view?.devicePixelRatio ?? 1.0;

    // Wait until end-of-frame so we don't capture mid-build.
    await SchedulerBinding.instance.endOfFrame;

    final image = await renderObject.toImage(pixelRatio: dpr);
    Uint8List? png;
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      png = bytes?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
    if (png == null) return null;

    final size = renderObject.size;
    final tree = treeBuilder.walk(ctx as Element);

    return Frame(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      devicePixelRatio: dpr,
      screenSize: ScreenSize(size.width, size.height),
      png: png,
      tree: tree,
    );
  }
}
