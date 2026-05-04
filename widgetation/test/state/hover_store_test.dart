import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/state/hover_store.dart';

import '../helpers/tree_node_factory.dart';

void main() {
  late HoverStore store;

  setUp(() => store = HoverStore());
  tearDown(() => store.dispose());

  test('starts empty', () {
    expect(store.value, HoverState.empty);
  });

  test('set updates node and cursor', () {
    final n = makeNode();
    store.set(n, const Offset(10, 20));
    expect(store.value.node, n);
    expect(store.value.cursor, const Offset(10, 20));
  });

  test('clear resets to empty', () {
    store.set(makeNode(), const Offset(1, 1));
    store.clear();
    expect(store.value.node, isNull);
    expect(store.value.cursor, isNull);
  });

  test('listeners fire on each set', () {
    var fires = 0;
    store.state.addListener(() => fires++);
    store.set(makeNode(), Offset.zero);
    store.set(null, null);
    expect(fires, 2);
  });
}
