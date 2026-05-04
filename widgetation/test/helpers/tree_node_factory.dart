import 'package:widgetation/src/tree_node.dart';

/// Build a [TreeNode] without walking a real element tree. Defaults match a
/// typical user-widget-owned `Text`; override fields to exercise edge cases.
TreeNode makeNode({
  String type = 'Text',
  int depth = 1,
  Rect rect = const Rect(0, 0, 100, 20),
  Map<String, String> props = const {'data': '"hi"'},
  String? key,
  String? file = '/proj/lib/foo.dart',
  int? line = 10,
  String? nearestWidget = 'Foo',
  List<String> ancestors = const ['Foo', 'Text'],
  List<TreeNode> children = const [],
}) =>
    TreeNode(
      type: type,
      depth: depth,
      rect: rect,
      widgetProperties: props,
      key: key,
      file: file,
      line: line,
      nearestWidget: nearestWidget,
      ancestors: ancestors,
      children: children,
    );
