import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/edits/chat_box_position.dart';

void main() {
  const screen = Size(800, 600);
  const insets = EdgeInsets.zero;
  const box = Size(200, 100);
  const gap = 12.0;

  group('chooseChatBoxPosition', () {
    test('prefers below + center when there is room', () {
      final p = chooseChatBoxPosition(
        anchor: const Offset(400, 300),
        box: box,
        screen: screen,
        insets: insets,
      );
      expect(p, Offset(400 - box.width / 2, 300 + gap));
    });

    test('falls back to above when bottom is too tight', () {
      final p = chooseChatBoxPosition(
        anchor: const Offset(400, 580),
        box: box,
        screen: screen,
        insets: insets,
      );
      // below would overflow at 580+12+100=692 > 600; above is 580-100-12=468
      expect(p, Offset(400 - box.width / 2, 580 - box.height - gap));
    });

    test('falls back to right-of-anchor when no vertical slot fits', () {
      // Screen 150 tall: below* (dy 62, bottom 162) and above* (dy -62) all
      // fail. Right-of-anchor vertically centered (dx 112, dy 0) is the
      // first candidate that fits.
      final p = chooseChatBoxPosition(
        anchor: const Offset(100, 50),
        box: const Size(200, 100),
        screen: const Size(800, 150),
        insets: insets,
      );
      expect(p.dx, 100 + gap);
      expect(p.dy, 0);
    });

    test('clamp fallback keeps result inside insets when nothing fits', () {
      // Box larger than screen: no candidate fits — caller falls through to
      // clamping the first (below+center) candidate into the safe area.
      const tight = Size(150, 80);
      const big = Size(120, 60);
      const safe = EdgeInsets.all(8);
      final p = chooseChatBoxPosition(
        anchor: const Offset(75, 40),
        box: big,
        screen: tight,
        insets: safe,
      );
      expect(p.dx, greaterThanOrEqualTo(safe.left));
      expect(p.dy, greaterThanOrEqualTo(safe.top));
      expect(p.dx + big.width, lessThanOrEqualTo(tight.width - safe.right));
      expect(p.dy + big.height, lessThanOrEqualTo(tight.height - safe.bottom));
    });

    test('honors non-zero insets when picking an axial slot', () {
      const safe = EdgeInsets.fromLTRB(40, 60, 40, 60);
      final p = chooseChatBoxPosition(
        anchor: const Offset(400, 300),
        box: box,
        screen: screen,
        insets: safe,
      );
      expect(p.dx, greaterThanOrEqualTo(safe.left));
      expect(p.dy, greaterThanOrEqualTo(safe.top));
      expect(p.dx + box.width, lessThanOrEqualTo(screen.width - safe.right));
      expect(p.dy + box.height, lessThanOrEqualTo(screen.height - safe.bottom));
    });

    test('custom gap shifts the chosen position', () {
      final p = chooseChatBoxPosition(
        anchor: const Offset(400, 300),
        box: box,
        screen: screen,
        insets: insets,
        gap: 30,
      );
      expect(p.dy, 300 + 30);
    });
  });
}
