import 'package:flutter/widgets.dart';

/// Package version surfaced in the settings popup. Bump alongside pubspec.
const String kWidgetationVersion = '0.1.0';

/// Marker color choices shown in the settings popup. Index 1 (blue) is the
/// out-of-the-box default; users pick another via [PreferencesStore].
const List<Color> kMarkerPalette = <Color>[
  Color(0xFF6355FE), // purple
  Color(0xFF008BFF), // blue
  Color(0xFF00C7D4), // cyan
  Color(0xFF00CA48), // green
  Color(0xFFFFC900), // yellow
  Color(0xFFFF8500), // orange
  Color(0xFFFF022D), // red
];

/// Color tokens used by every drawn surface in the package. Built by the
/// host wrapper from a [PreferencesState] (theme mode + marker color) and
/// pushed down via [WidgetationTheme]. Consumers read tokens with
/// `WidgetationTheme.of(context).surface` etc.
@immutable
class WidgetationThemeData {
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceElevated;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color divider;
  final Color shadow;
  final Color accent;
  final Color onAccent;
  final Brightness brightness;

  const WidgetationThemeData({
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceElevated,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.divider,
    required this.shadow,
    required this.accent,
    required this.onAccent,
    required this.brightness,
  });

  WidgetationThemeData withAccent(Color color) => WidgetationThemeData(
    surface: surface,
    surfaceMuted: surfaceMuted,
    surfaceElevated: surfaceElevated,
    onSurface: onSurface,
    onSurfaceMuted: onSurfaceMuted,
    divider: divider,
    shadow: shadow,
    accent: color,
    onAccent: onAccent,
    brightness: brightness,
  );

  @override
  bool operator ==(Object other) {
    return other is WidgetationThemeData &&
        other.surface == surface &&
        other.surfaceMuted == surfaceMuted &&
        other.surfaceElevated == surfaceElevated &&
        other.onSurface == onSurface &&
        other.onSurfaceMuted == onSurfaceMuted &&
        other.divider == divider &&
        other.shadow == shadow &&
        other.accent == accent &&
        other.onAccent == onAccent &&
        other.brightness == brightness;
  }

  @override
  int get hashCode => Object.hash(
    surface,
    surfaceMuted,
    surfaceElevated,
    onSurface,
    onSurfaceMuted,
    divider,
    shadow,
    accent,
    onAccent,
    brightness,
  );
}

/// Dark surface palette — preserves the existing pre-theming look.
const WidgetationThemeData kWidgetationDarkTheme = WidgetationThemeData(
  surface: Color(0xFF1A1A1A),
  surfaceMuted: Color(0xFF222222),
  surfaceElevated: Color(0xEE111111),
  onSurface: Color(0xFFFFFFFF),
  onSurfaceMuted: Color.fromARGB(111, 255, 255, 255),
  divider: Color(0x12FFFFFF),
  shadow: Color(0x33000000),
  brightness: Brightness.dark,
  accent: Color(0xFF06B6D4),
  onAccent: Color(0xFFFFFFFF),
);

/// Light surface palette — paired with [kWidgetationDarkTheme] via the
/// theme toggle in the settings popup.
const WidgetationThemeData kWidgetationLightTheme = WidgetationThemeData(
  surface: Color(0xFFFFFFFF),
  surfaceMuted: Color(0xFFF4F4F5),
  surfaceElevated: Color(0xFF0F172A),
  onSurface: Color(0xFF0F172A),
  onSurfaceMuted: Color(0xFF64748B),
  divider: Color(0xFFE4E4E7),
  shadow: Color(0x1A0F172A),
  brightness: Brightness.light,
  accent: Color(0xFF06B6D4),
  onAccent: Color(0xFFFFFFFF),
);

/// Inherited carrier for [WidgetationThemeData]. Mounted once by the host
/// wrapper so descendants don't each subscribe to [PreferencesStore].
class WidgetationTheme extends InheritedWidget {
  final WidgetationThemeData data;

  const WidgetationTheme({super.key, required this.data, required super.child});

  static WidgetationThemeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<WidgetationTheme>();
    assert(scope != null, 'No WidgetationTheme found in context');
    return scope!.data;
  }

  static WidgetationThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WidgetationTheme>()?.data;

  @override
  bool updateShouldNotify(WidgetationTheme old) => old.data != data;
}
