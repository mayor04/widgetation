import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/state/edits_store.dart';
import 'package:widgetation/src/tree_node.dart' as wt;

import '../helpers/tree_node_factory.dart';

void main() {
  late EditsStore store;

  setUp(() => store = EditsStore());
  tearDown(() => store.dispose());

  group('beginCompose', () {
    test('opens a fresh draft anchored at cursor', () {
      final n = makeNode(file: '/proj/lib/a.dart');
      store.beginCompose(cursor: const Offset(50, 60), node: n);
      final d = store.value.draft!;
      expect(d.cursor, const Offset(50, 60));
      expect(d.nodes, [n]);
      expect(d.text, '');
      expect(d.files, ['/proj/lib/a.dart']);
      expect(d.editingId, isNull);
      expect(d.isEditing, isFalse);
    });

    test('no-op when a draft is already open', () {
      final a = makeNode(type: 'A');
      final b = makeNode(type: 'B');
      store.beginCompose(cursor: Offset.zero, node: a);
      final before = store.value.draft;
      store.beginCompose(cursor: const Offset(99, 99), node: b);
      expect(identical(store.value.draft, before), isTrue);
    });

    test('null ancestors when node has none', () {
      final n = makeNode(ancestors: const []);
      store.beginCompose(cursor: Offset.zero, node: n);
      expect(store.value.draft!.ancestors, isNull);
    });
  });

  group('beginComposeMulti', () {
    test('records selectRect and uses first node ancestors', () {
      final a = makeNode(type: 'A', ancestors: const ['Root', 'A']);
      final b = makeNode(type: 'B', ancestors: const ['Root', 'B']);
      store.beginComposeMulti(
        cursor: const Offset(10, 20),
        nodes: [a, b],
        selectRect: const Rect.fromLTWH(0, 0, 100, 50),
      );
      final d = store.value.draft!;
      expect(d.nodes, [a, b]);
      expect(d.selectRect, const Rect.fromLTWH(0, 0, 100, 50));
      expect(d.ancestors, const ['Root', 'A']);
    });

    test('empty list is a no-op', () {
      store.beginComposeMulti(
        cursor: Offset.zero,
        nodes: const [],
        selectRect: Rect.zero,
      );
      expect(store.value.draft, isNull);
    });

    test('no-op when a draft is already open', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      final before = store.value.draft;
      store.beginComposeMulti(
        cursor: const Offset(99, 99),
        nodes: [makeNode(type: 'X')],
        selectRect: const Rect.fromLTWH(0, 0, 1, 1),
      );
      expect(identical(store.value.draft, before), isTrue);
    });
  });

  group('shake', () {
    test('increments shakeNonce', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      final before = store.value.draft!.shakeNonce;
      store.shake();
      expect(store.value.draft!.shakeNonce, before + 1);
    });

    test('no-op when no draft', () {
      var fires = 0;
      store.draft.addListener(() => fires++);
      store.shake();
      expect(fires, 0);
    });
  });

  group('cancelDraft', () {
    test('drops draft and keeps edits', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('one');
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.cancelDraft();
      expect(store.value.draft, isNull);
      expect(store.value.edits, hasLength(1));
    });

    test('no-op when no draft is open', () {
      var fires = 0;
      store.state.addListener(() => fires++);
      store.cancelDraft();
      expect(fires, 0);
    });
  });

  group('commitDraft', () {
    test('whitespace-only text cancels without appending', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('   \n');
      expect(store.value.edits, isEmpty);
      expect(store.value.draft, isNull);
    });

    test('appends a new edit with sequential index and id', () {
      store.beginCompose(cursor: const Offset(1, 1), node: makeNode());
      store.commitDraft('first');
      store.beginCompose(cursor: const Offset(2, 2), node: makeNode());
      store.commitDraft('second');
      expect(store.value.edits.map((e) => e.index), [1, 2]);
      expect(store.value.edits.map((e) => e.id), ['edit-1', 'edit-2']);
    });

    test('trims leading/trailing whitespace', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('  hi  ');
      expect(store.value.edits.single.text, 'hi');
    });

    test('editing existing replaces text, preserves id/index/createdAt', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('orig');
      final original = store.value.edits.single;

      store.editExisting(original.id);
      store.commitDraft('updated');

      final updated = store.value.edits.single;
      expect(updated.id, original.id);
      expect(updated.index, original.index);
      expect(updated.createdAt, original.createdAt);
      expect(updated.text, 'updated');
    });
  });

  group('editExisting', () {
    test('opens a draft mirroring the edit', () {
      final n = makeNode();
      store.beginCompose(cursor: const Offset(5, 6), node: n);
      store.commitDraft('hi');
      final id = store.value.edits.single.id;

      store.editExisting(id);
      final d = store.value.draft!;
      expect(d.editingId, id);
      expect(d.text, 'hi');
      expect(d.cursor, const Offset(5, 6));
    });

    test('no-op for unknown id', () {
      store.editExisting('does-not-exist');
      expect(store.value.draft, isNull);
    });

    test('no-op when a draft is already open', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('a');
      final id = store.value.edits.single.id;
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      final before = store.value.draft;
      store.editExisting(id);
      expect(identical(store.value.draft, before), isTrue);
    });
  });

  group('delete', () {
    test('renumbers remaining edits contiguously', () {
      for (var i = 0; i < 3; i++) {
        store.beginCompose(cursor: Offset.zero, node: makeNode());
        store.commitDraft('e$i');
      }
      final secondId = store.value.edits[1].id;
      store.delete(secondId);
      expect(store.value.edits.map((e) => e.index), [1, 2]);
      expect(store.value.edits.map((e) => e.text), ['e0', 'e2']);
    });

    test('dismisses draft when deleting the same id being edited', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('one');
      final id = store.value.edits.single.id;
      store.editExisting(id);
      store.delete(id);
      expect(store.value.draft, isNull);
    });

    test('keeps draft when deleting a different id', () {
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('a');
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('b');
      final firstId = store.value.edits.first.id;
      store.editExisting(store.value.edits.last.id);
      store.delete(firstId);
      expect(store.value.draft, isNotNull);
    });
  });

  test('clear resets state; no-op when already empty', () {
    var fires = 0;
    store.state.addListener(() => fires++);
    store.clear();
    expect(fires, 0);

    store.beginCompose(cursor: Offset.zero, node: makeNode());
    store.commitDraft('a');
    store.clear();
    expect(store.value, EditsState.empty);
  });

  test('toggleHidden flips hidden, preserves edits + draft', () {
    store.beginCompose(cursor: Offset.zero, node: makeNode());
    store.commitDraft('a');
    store.beginCompose(cursor: Offset.zero, node: makeNode());
    store.toggleHidden();
    expect(store.value.hidden, isTrue);
    expect(store.value.edits, hasLength(1));
    expect(store.value.draft, isNotNull);
    store.toggleHidden();
    expect(store.value.hidden, isFalse);
  });

  group('listenable slices', () {
    test('list slice fires on commit + toggleHidden, not on shake', () {
      var fires = 0;
      store.list.addListener(() => fires++);
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      expect(fires, 0); // begin doesn't change list
      store.commitDraft('a');
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.shake();
      expect(fires, 1); // only the commit
      store.toggleHidden();
      expect(fires, 2);
    });

    test('draft slice fires on begin/cancel/commit/shake', () {
      var fires = 0;
      store.draft.addListener(() => fires++);
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.shake();
      store.cancelDraft();
      store.beginCompose(cursor: Offset.zero, node: makeNode());
      store.commitDraft('x');
      expect(fires, 5);
    });

    test('hasDraftText is independent of state listenable', () {
      var stateFires = 0;
      store.state.addListener(() => stateFires++);
      store.setHasDraftText(true);
      store.setHasDraftText(false);
      expect(stateFires, 0);
      expect(store.hasDraftText.value, isFalse);
    });
  });

  test('Edit.copyWith updates only text', () {
    final e = Edit(
      id: 'edit-1',
      index: 1,
      cursor: const Offset(1, 2),
      nodes: <wt.TreeNode>[makeNode()],
      text: 'old',
      files: const ['/f'],
      createdAt: DateTime(2026, 1, 1),
    );
    final out = e.copyWith(text: 'new');
    expect(out.text, 'new');
    expect(out.id, e.id);
    expect(out.index, e.index);
    expect(out.cursor, e.cursor);
    expect(out.createdAt, e.createdAt);
  });
}
