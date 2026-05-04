import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/edits/edit_label.dart';

import '../helpers/tree_node_factory.dart';

void main() {
  group('formatNodeLabel', () {
    test('appends quoted excerpt from "data" property', () {
      final n = makeNode(type: 'Text', props: {'data': 'hello'});
      expect(formatNodeLabel(n), 'Text (hello)');
    });

    test('falls back through data → text → label → title', () {
      expect(formatNodeLabel(makeNode(props: {'text': 'one'})),
          'Text (one)');
      expect(formatNodeLabel(makeNode(props: {'label': 'two'})),
          'Text (two)');
      expect(formatNodeLabel(makeNode(props: {'title': 'three'})),
          'Text (three)');
    });

    test('truncates excerpts longer than 32 chars with ellipsis', () {
      final long = 'a' * 40;
      final out = formatNodeLabel(makeNode(props: {'data': long}));
      expect(out, 'Text (${'a' * 32}…)');
    });

    test('passes through 32-char excerpt unchanged', () {
      final exact = 'a' * 32;
      expect(formatNodeLabel(makeNode(props: {'data': exact})),
          'Text ($exact)');
    });

    test('no recognized property → uses nearestWidget(type) form', () {
      final n = makeNode(type: 'Text', nearestWidget: 'Foo', props: const {});
      expect(formatNodeLabel(n), 'Foo(Text)');
    });

    test('empty nearestWidget collapses to bare (type)', () {
      final n = makeNode(type: 'Padding', nearestWidget: '', props: const {});
      expect(formatNodeLabel(n), '(Padding)');
    });

    test('skips empty property values when scanning fallback keys', () {
      final n = makeNode(props: {'data': '', 'text': 'real'});
      expect(formatNodeLabel(n), 'Text (real)');
    });
  });

  group('formatMultiNodeLabel', () {
    test('empty list → empty string', () {
      expect(formatMultiNodeLabel(const []), '');
    });

    test('single node delegates to formatNodeLabel', () {
      final n = makeNode(props: {'data': 'hi'});
      expect(formatMultiNodeLabel([n]), formatNodeLabel(n));
    });

    test('multi-node appends +N (count of others)', () {
      final a = makeNode(props: {'data': 'a'});
      final b = makeNode(props: {'data': 'b'});
      final c = makeNode(props: {'data': 'c'});
      expect(formatMultiNodeLabel([a, b, c]), 'Text (a) +2');
    });
  });
}
