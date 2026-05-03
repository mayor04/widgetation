import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import 'widgetation_store.dart';

enum WidgetationThemeMode { dark, light }

@immutable
class PreferencesState {
  final WidgetationThemeMode themeMode;
  final int markerColorIndex;
  final bool clearOnCopy;

  const PreferencesState({
    this.themeMode = WidgetationThemeMode.dark,
    this.markerColorIndex = 2,
    this.clearOnCopy = false,
  });

  PreferencesState copyWith({
    WidgetationThemeMode? themeMode,
    int? markerColorIndex,
    bool? clearOnCopy,
  }) =>
      PreferencesState(
        themeMode: themeMode ?? this.themeMode,
        markerColorIndex: markerColorIndex ?? this.markerColorIndex,
        clearOnCopy: clearOnCopy ?? this.clearOnCopy,
      );

  Color get markerColor =>
      kMarkerPalette[markerColorIndex.clamp(0, kMarkerPalette.length - 1)];
}

/// User-tweakable preferences shown in the settings popup. Backed by
/// [SharedPreferences]; reads happen async at boot so first frames see
/// defaults until [load] resolves.
class PreferencesStore extends WidgetationStore<PreferencesState> {
  PreferencesStore() : super(const PreferencesState());

  static const _kThemeMode = 'widgetation.themeMode';
  static const _kMarkerIndex = 'widgetation.markerColorIndex';
  static const _kClearOnCopy = 'widgetation.clearOnCopy';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      emit(PreferencesState(
        themeMode: _readTheme(prefs) ?? value.themeMode,
        markerColorIndex: prefs.getInt(_kMarkerIndex) ?? value.markerColorIndex,
        clearOnCopy: prefs.getBool(_kClearOnCopy) ?? value.clearOnCopy,
      ));
    } catch (e) {
      debugPrint('[widgetation] preferences load failed: $e');
    }
  }

  Future<void> setThemeMode(WidgetationThemeMode mode) async {
    if (value.themeMode == mode) return;
    emit(value.copyWith(themeMode: mode));
    _writeString(_kThemeMode, mode.name);
  }

  Future<void> setMarkerColorIndex(int index) async {
    final clamped = index.clamp(0, kMarkerPalette.length - 1);
    if (value.markerColorIndex == clamped) return;
    emit(value.copyWith(markerColorIndex: clamped));
    _writeInt(_kMarkerIndex, clamped);
  }

  Future<void> setClearOnCopy(bool enabled) async {
    if (value.clearOnCopy == enabled) return;
    emit(value.copyWith(clearOnCopy: enabled));
    _writeBool(_kClearOnCopy, enabled);
  }

  WidgetationThemeMode? _readTheme(SharedPreferences prefs) {
    final raw = prefs.getString(_kThemeMode);
    if (raw == null) return null;
    for (final m in WidgetationThemeMode.values) {
      if (m.name == raw) return m;
    }
    return null;
  }

  Future<void> _writeString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('[widgetation] preferences write $key failed: $e');
    }
  }

  Future<void> _writeInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } catch (e) {
      debugPrint('[widgetation] preferences write $key failed: $e');
    }
  }

  Future<void> _writeBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('[widgetation] preferences write $key failed: $e');
    }
  }
}
