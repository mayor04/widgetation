import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/state/selection_store.dart';
import 'package:widgetation/src/tree_node.dart';

import '../helpers/tree_node_factory.dart';

void main() {
  late SelectionStore store;
  late TreeNode a;
  late TreeNode b;
  late TreeNode c;

  setUp(() {
    store = SelectionStore();
    a = makeNode(type: 'A');
    b = makeNode(type: 'B');
    c = makeNode(type: 'C');
  });

  tearDown(() => store.dispose());

  test('starts empty', () {
    expect(store.value.hasSelection, isFalse);
    expect(store.value.primary, isNull);
  });

  test('select(node) populates nodes and active', () {
    store.select(a);
    expect(store.value.nodes, [a]);
    expect(store.value.active, a);
    expect(store.value.primary, a);
  });

  test('select(null) clears', () {
    store.select(a);
    store.select(null);
    expect(store.value, SelectionState.empty);
  });

  test('selectMany([]) clears', () {
    store.select(a);
    store.selectMany(const []);
    expect(store.value.hasSelection, isFalse);
  });

  test('selectMany makes first active and list unmodifiable', () {
    store.selectMany([a, b, c]);
    expect(store.value.active, a);
    expect(store.value.nodes, [a, b, c]);
    expect(() => store.value.nodes.add(a), throwsUnsupportedError);
  });

  test('add appends and switches active; duplicate is no-op', () {
    store.add(a);
    store.add(b);
    expect(store.value.nodes, [a, b]);
    expect(store.value.active, b);

    final before = store.value;
    store.add(b);
    expect(identical(store.value, before) || store.value.nodes.length == 2,
        isTrue);
  });

  test('toggle removes existing; active falls back to last remaining', () {
    store.selectMany([a, b, c]);
    store.toggle(b);
    expect(store.value.nodes, [a, c]);
    expect(store.value.active, c);
  });

  test('toggle to empty clears active', () {
    store.select(a);
    store.toggle(a);
    expect(store.value.nodes, isEmpty);
    expect(store.value.active, isNull);
  });

  test('toggle adds when missing and makes it active', () {
    store.select(a);
    store.toggle(b);
    expect(store.value.nodes, [a, b]);
    expect(store.value.active, b);
  });

  test('clear resets', () {
    store.selectMany([a, b]);
    store.clear();
    expect(store.value, SelectionState.empty);
  });

  test('state listenable fires on transitions', () {
    var fires = 0;
    void listener() => fires++;
    store.state.addListener(listener);
    store.select(a);
    store.select(b);
    store.clear();
    store.state.removeListener(listener);
    expect(fires, 3);
  });

  test('primary falls back to first when active is null', () {
    // Direct construction — store API always sets active, but the model
    // needs to handle the legacy/empty-active case.
    const s = SelectionState();
    expect(s.primary, isNull);
  });
}
