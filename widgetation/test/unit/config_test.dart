import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  group('WidgetationConfig', () {
    test('defaults are enabled + edit + bottomRight', () {
      const c = WidgetationConfig();
      expect(c.enabled, isTrue);
      expect(c.mode, WidgetationMode.edit);
      expect(c.selectButtonAlignment, Alignment.bottomRight);
      expect(c.isActive, isTrue);
    });

    test('isActive false when disabled', () {
      const c = WidgetationConfig(enabled: false);
      expect(c.isActive, isFalse);
    });

    test('isActive false when mode is none', () {
      const c = WidgetationConfig(mode: WidgetationMode.none);
      expect(c.isActive, isFalse);
    });

    test('isActive false when both disabled and none', () {
      const c = WidgetationConfig(enabled: false, mode: WidgetationMode.none);
      expect(c.isActive, isFalse);
    });
  });
}
