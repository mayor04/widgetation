import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/widget_picker.dart';

void main() {
  testWidgets('reports nearest non-flutter ancestor and chain', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _Host()));
    await tester.pump();

    final picker = WidgetPicker();
    final root = WidgetsBinding.instance.rootElement;
    expect(root, isNotNull);

    final textCenter = tester.getCenter(find.text('hi'));
    final node = picker.findAt(root!, textCenter);

    expect(node, isNotNull, reason: 'picker should find a node under "hi"');
    expect(node!.ancestors.last, equals(node.type));
    expect(node.ancestors.length, lessThanOrEqualTo(4));
    expect(node.ancestors.length, greaterThan(1));
    // The wrapping user widget is _MyCustom; its private "_" prefix means we
    // fall back to the file path for the label, but it must point at this
    // test file (not a flutter SDK file).
    expect(node.nearestWidget, isNotNull);
    expect(node.nearestWidget, isNot(contains('/packages/flutter/')));
    // "data: hi" is the canonical Text diagnostic.
    expect(node.widgetProperties['data'], equals('"hi"'));
  });

  testWidgets('returns null when point is outside everything', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _Host()));
    await tester.pump();
    final picker = WidgetPicker();
    final root = WidgetsBinding.instance.rootElement!;
    expect(picker.findAt(root, const Offset(-1000, -1000)), isNull);
  });
}

class _Host extends StatelessWidget {
  const _Host();
  @override
  Widget build(BuildContext context) => const Center(child: _MyCustom());
}

class _MyCustom extends StatelessWidget {
  const _MyCustom();
  @override
  Widget build(BuildContext context) => const Text('hi');
}
