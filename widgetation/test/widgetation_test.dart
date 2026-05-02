import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  test('WidgetationConfig clamps fps', () {
    expect(const WidgetationConfig(fps: 0).clampedFps, 1);
    expect(const WidgetationConfig(fps: 999).clampedFps, 30);
    expect(const WidgetationConfig(fps: 12).clampedFps, 12);
  });
}
