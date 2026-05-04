import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  testWidgets('Widgetation renders its child when disabled', (tester) async {
    await tester.pumpWidget(
      const Widgetation(
        config: WidgetationConfig(enabled: false),
        child: MaterialApp(home: Text('hello')),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
  });
}
