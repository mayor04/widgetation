import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/state/ui_state_store.dart';

void main() {
  late UiStateStore store;

  setUp(() => store = UiStateStore());
  tearDown(() => store.dispose());

  test('defaults: select inactive, settings closed, no marquee', () {
    expect(store.selectActive.value, isFalse);
    expect(store.settingsOpen.value, isFalse);
    expect(store.marquee.value, isNull);
  });

  test('selectActive notifier is independent of marquee', () {
    var marqueeFires = 0;
    store.marquee.addListener(() => marqueeFires++);
    store.selectActive.value = true;
    expect(marqueeFires, 0);
  });

  test('marquee notifier is independent of settingsOpen', () {
    var settingsFires = 0;
    store.settingsOpen.addListener(() => settingsFires++);
    store.marquee.value = const Rect.fromLTWH(0, 0, 10, 10);
    expect(settingsFires, 0);
  });
}
