import 'package:flutter/widgets.dart';

/// Choose a top-left for a chat box of [box] size, anchored to [anchor],
/// constrained to a [screen] of the given size with safe-area [insets].
/// Tries below, above, right, left, then diagonals — first that fits wins.
/// Falls back to clamping the most-natural choice into bounds.
Offset chooseChatBoxPosition({
  required Offset anchor,
  required Size box,
  required Size screen,
  required EdgeInsets insets,
  double gap = 12,
}) {
  final candidates = <Offset>[
    // Below + center.
    Offset(anchor.dx - box.width / 2, anchor.dy + gap),
    // Above + center.
    Offset(anchor.dx - box.width / 2, anchor.dy - box.height - gap),
    // Below + right.
    Offset(anchor.dx + gap, anchor.dy + gap),
    // Below + left.
    Offset(anchor.dx - box.width - gap, anchor.dy + gap),
    // Above + right.
    Offset(anchor.dx + gap, anchor.dy - box.height - gap),
    // Above + left.
    Offset(anchor.dx - box.width - gap, anchor.dy - box.height - gap),
    // Right of, vertically centered.
    Offset(anchor.dx + gap, anchor.dy - box.height / 2),
    // Left of, vertically centered.
    Offset(anchor.dx - box.width - gap, anchor.dy - box.height / 2),
  ];

  for (final c in candidates) {
    if (_fits(c, box, screen, insets)) return c;
  }

  final fallback = candidates.first;
  final maxX = (screen.width - insets.right - box.width).clamp(insets.left, double.infinity);
  final maxY = (screen.height - insets.bottom - box.height).clamp(insets.top, double.infinity);
  return Offset(
    fallback.dx.clamp(insets.left, maxX),
    fallback.dy.clamp(insets.top, maxY),
  );
}

bool _fits(Offset topLeft, Size box, Size screen, EdgeInsets insets) {
  return topLeft.dx >= insets.left &&
      topLeft.dy >= insets.top &&
      topLeft.dx + box.width <= screen.width - insets.right &&
      topLeft.dy + box.height <= screen.height - insets.bottom;
}
