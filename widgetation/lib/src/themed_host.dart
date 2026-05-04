import 'package:flutter/widgets.dart';

import 'state/preferences_store.dart';
import 'state/widgetation_store.dart';
import 'theme.dart';

/// Subscribes to [PreferencesStore] and republishes the resulting
/// [WidgetationThemeData] via [WidgetationTheme]. Scoped per consumer
/// so theme changes don't bubble through the entire widget tree — only
/// the subtree below this host rebuilds.
class ThemedHost extends StatelessWidget {
  final Widget child;

  const ThemedHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<PreferencesStore, PreferencesState>(
      builder: (context, prefs) {
        final base = prefs.themeMode == WidgetationThemeMode.light
            ? kWidgetationLightTheme
            : kWidgetationDarkTheme;
        final theme = base.withAccent(prefs.markerColor);
        return WidgetationTheme(data: theme, child: child);
      },
    );
  }
}
