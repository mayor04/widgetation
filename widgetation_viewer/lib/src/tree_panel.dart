import 'package:flutter/material.dart';

import 'frame.dart' as proto;

/// Right-hand side panel: full collapsible widget tree on top, properties
/// panel for the selected node on the bottom (properties content lands in
/// a subsequent commit).
class TreePanel extends StatefulWidget {
  final proto.InspectorFrame? frame;
  final proto.TreeNode? selected;
  final ValueChanged<proto.TreeNode> onSelect;

  const TreePanel({
    super.key,
    required this.frame,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<TreePanel> createState() => _TreePanelState();
}

class _TreePanelState extends State<TreePanel> {
  final Set<int> _expanded = <int>{};

  @override
  Widget build(BuildContext context) {
    final f = widget.frame;
    if (f == null) {
      return const Center(child: Text('No frame yet'));
    }
    final rows = <_Row>[];
    for (final root in f.tree) {
      _flatten(root, rows);
    }
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final row = rows[i];
              final node = row.node;
              final isSelected = identical(node, widget.selected);
              return InkWell(
                onTap: () => widget.onSelect(node),
                child: Container(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  padding: EdgeInsets.only(
                    left: 8.0 + row.indent * 14.0,
                    right: 8,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: node.children.isEmpty
                            ? const SizedBox.shrink()
                            : InkWell(
                                onTap: () => setState(() {
                                  final id = identityHashCode(node);
                                  if (!_expanded.add(id)) _expanded.remove(id);
                                }),
                                child: Icon(
                                  _expanded.contains(identityHashCode(node))
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_right,
                                  size: 16,
                                ),
                              ),
                      ),
                      Expanded(
                        child: Text(
                          node.type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        const Expanded(flex: 2, child: SizedBox.shrink()),
      ],
    );
  }

  void _flatten(proto.TreeNode node, List<_Row> out, [int indent = 0]) {
    out.add(_Row(node, indent));
    if (_expanded.contains(identityHashCode(node))) {
      for (final c in node.children) {
        _flatten(c, out, indent + 1);
      }
    }
  }
}

class _Row {
  final proto.TreeNode node;
  final int indent;
  _Row(this.node, this.indent);
}
