import 'package:flutter/widgets.dart';

/// Ephemeral inspector UI state that doesn't belong in any of the domain
/// stores: select-mode toggle, settings popup visibility, and the live
/// marquee rect. Each is a bare [ValueNotifier] so consumers can subscribe
/// to exactly one signal via [ValueListenableBuilder] and skip rebuilds
/// when the others change.
///
/// Owned and disposed by the host widgetation state.
class UiStateStore {
  final ValueNotifier<bool> selectActive = ValueNotifier(false);
  final ValueNotifier<bool> settingsOpen = ValueNotifier(false);
  final ValueNotifier<Rect?> marquee = ValueNotifier(null);

  void dispose() {
    selectActive.dispose();
    settingsOpen.dispose();
    marquee.dispose();
  }
}
