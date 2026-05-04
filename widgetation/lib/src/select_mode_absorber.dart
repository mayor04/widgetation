import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Rebuilds only when `selectActive` flips. Mounts a full-screen
/// `AbsorbPointer` so taps and pans don't reach the user's app while
/// the inspector owns input. Mouse-wheel and trackpad two-finger pan
/// events are forwarded to the underlying scrollable manually by the
/// inspector layer instead.
class SelectModeAbsorber extends StatelessWidget {
  final ValueListenable<bool> active;

  const SelectModeAbsorber({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: active,
      builder: (context, on, _) {
        if (!on) return const SizedBox.shrink();
        return const Positioned.fill(
          child: RepaintBoundary(
            child: AbsorbPointer(child: SizedBox.expand()),
          ),
        );
      },
    );
  }
}
