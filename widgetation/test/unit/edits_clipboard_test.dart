import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/edits_clipboard.dart';
import 'package:widgetation/src/state/edits_store.dart';

import '../helpers/tree_node_factory.dart';

Edit _edit({
  required int index,
  required String text,
  String? file = '/proj/lib/foo.dart',
  int? line = 10,
  int nodes = 1,
}) {
  final ns = [
    for (var i = 0; i < nodes; i++)
      makeNode(file: file, line: line == null ? null : line + i),
  ];
  return Edit(
    id: 'edit-$index',
    index: index,
    cursor: Offset.zero,
    nodes: ns,
    text: text,
    files: [for (final n in ns) n.file],
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

void main() {
  group('formatEditsForClipboard', () {
    test('empty list returns header only (trimmed)', () {
      expect(formatEditsForClipboard(const []),
          '### **Page Feedback List**');
    });

    test('numbered entries with file:line source and feedback', () {
      final out = formatEditsForClipboard([
        _edit(index: 1, text: 'looks off'),
      ]);
      expect(out, contains('1. Text ("hi")'));
      expect(out, contains('Source: /proj/lib/foo.dart:10'));
      expect(out, contains('Feedback: looks off'));
      expect(out, startsWith('### **Page Feedback List**'));
    });

    test('multi-node sources joined and dedup\'d', () {
      final out = formatEditsForClipboard([
        _edit(index: 1, text: 't', nodes: 2),
      ]);
      expect(out, contains('Source: /proj/lib/foo.dart:10, /proj/lib/foo.dart:11'));
    });

    test('null file collapses to (unknown) source', () {
      final out = formatEditsForClipboard([
        _edit(index: 1, text: 't', file: null, line: null),
      ]);
      expect(out, contains('Source: (unknown)'));
    });

    test('preserves edit order', () {
      final out = formatEditsForClipboard([
        _edit(index: 1, text: 'first'),
        _edit(index: 2, text: 'second'),
      ]);
      final firstAt = out.indexOf('1. ');
      final secondAt = out.indexOf('2. ');
      expect(firstAt, isNonNegative);
      expect(secondAt, greaterThan(firstAt));
    });

    test('no trailing blank line', () {
      final out = formatEditsForClipboard([_edit(index: 1, text: 't')]);
      expect(out.endsWith('\n'), isFalse);
    });
  });
}
