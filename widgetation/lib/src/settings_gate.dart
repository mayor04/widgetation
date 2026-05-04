import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'themed_host.dart';
import 'toolbar/status_popup.dart';

/// Mounts the settings popup only while `open` is true. Hosts its own
/// theme consumer so opening/closing it doesn't ripple to the toolbar
/// or the select-mode overlay.
class SettingsGate extends StatelessWidget {
  final ValueListenable<bool> open;
  final VoidCallback onDismiss;

  const SettingsGate({
    super.key,
    required this.open,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: open,
      builder: (context, isOpen, _) {
        if (!isOpen) return const SizedBox.shrink();
        return ThemedHost(
          child: RepaintBoundary(
            child: ToolbarStatusPopup(onDismiss: onDismiss),
          ),
        );
      },
    );
  }
}
