import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgetation/src/state/preferences_store.dart';
import 'package:widgetation/src/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults match PreferencesState() before load', () {
    final store = PreferencesStore();
    expect(store.value.themeMode, WidgetationThemeMode.dark);
    expect(store.value.markerColorIndex, 1);
    expect(store.value.clearOnCopy, isFalse);
    store.dispose();
  });

  test('load reads stored values', () async {
    SharedPreferences.setMockInitialValues({
      'widgetation.themeMode': 'light',
      'widgetation.markerColorIndex': 3,
      'widgetation.clearOnCopy': true,
    });
    final store = PreferencesStore();
    await store.load();
    expect(store.value.themeMode, WidgetationThemeMode.light);
    expect(store.value.markerColorIndex, 3);
    expect(store.value.clearOnCopy, isTrue);
    store.dispose();
  });

  test('load ignores unknown theme string and keeps default', () async {
    SharedPreferences.setMockInitialValues({
      'widgetation.themeMode': 'space-grey',
    });
    final store = PreferencesStore();
    await store.load();
    expect(store.value.themeMode, WidgetationThemeMode.dark);
    store.dispose();
  });

  test('setThemeMode no-op when unchanged', () async {
    final store = PreferencesStore();
    var fires = 0;
    store.state.addListener(() => fires++);
    await store.setThemeMode(WidgetationThemeMode.dark); // already dark
    expect(fires, 0);
    store.dispose();
  });

  test('setThemeMode emits and persists when changed', () async {
    final store = PreferencesStore();
    await store.setThemeMode(WidgetationThemeMode.light);
    expect(store.value.themeMode, WidgetationThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('widgetation.themeMode'), 'light');
    store.dispose();
  });

  test('setMarkerColorIndex clamps to palette bounds', () async {
    final store = PreferencesStore();
    await store.setMarkerColorIndex(999);
    expect(store.value.markerColorIndex, kMarkerPalette.length - 1);

    await store.setMarkerColorIndex(-5);
    expect(store.value.markerColorIndex, 0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('widgetation.markerColorIndex'), 0);
    store.dispose();
  });

  test('setClearOnCopy toggles and persists', () async {
    final store = PreferencesStore();
    await store.setClearOnCopy(true);
    expect(store.value.clearOnCopy, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('widgetation.clearOnCopy'), isTrue);
    store.dispose();
  });

  test('markerColor returns palette entry for current index', () {
    final s = const PreferencesState(markerColorIndex: 2);
    expect(s.markerColor, kMarkerPalette[2]);
  });

  test('markerColor clamps an out-of-range stored index', () {
    const s = PreferencesState(markerColorIndex: 99);
    expect(s.markerColor, kMarkerPalette.last);
  });
}
