import 'package:flutter/material.dart';

import 'frame.dart' as proto;

/// Right-hand side panel: full collapsible widget tree on top, properties
/// panel for the selected node on the bottom.
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
                            fontWeight: node.isFlutterWidget
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : node.isFlutterWidget
                                    ? null
                                    : Theme.of(context).colorScheme.primary,
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
        Expanded(flex: 2, child: _PropertyView(node: widget.selected)),
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

class _PropertyView extends StatelessWidget {
  final proto.TreeNode? node;
  const _PropertyView({required this.node});

  @override
  Widget build(BuildContext context) {
    final n = node;
    if (n == null) {
      return const Center(child: Text('Hover a widget to inspect'));
    }
    final small = Theme.of(context).textTheme.bodySmall;
    final mono = small?.copyWith(fontFamily: 'monospace');
    final muted = small?.copyWith(
      fontFamily: 'monospace',
      color: Theme.of(context).colorScheme.outline,
    );
    final parent = n.parent;
    final ancestors = n.topAncestors(4);
    final closest = n.nearestNonFlutterAncestor;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          n.type,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'depth ${n.depth} • '
          '${n.w.toStringAsFixed(1)}×${n.h.toStringAsFixed(1)} '
          '@ (${n.x.toStringAsFixed(1)}, ${n.y.toStringAsFixed(1)})',
          style: small,
        ),
        if (n.key != null) ...[
          const SizedBox(height: 4),
          Text('key: ${n.key}', style: small),
        ],
        const SizedBox(height: 12),
        Text('Parent', style: small),
        Text(parent?.type ?? '(none)', style: mono),
        const SizedBox(height: 8),
        Text('Top 4 ancestors', style: small),
        if (ancestors.isEmpty)
          Text('(none)', style: mono)
        else
          ...ancestors.map((a) => Text(a.type, style: mono)),
        const SizedBox(height: 8),
        Text('Closest non-flutter ancestor', style: small),
        if (closest == null)
          Text('(none)', style: mono)
        else ...[
          Text(closest.type, style: mono),
          if (closest.file != null)
            Text(
              closest.line != null
                  ? '${closest.file}:${closest.line}'
                  : closest.file!,
              style: muted,
            ),
        ],
        const Divider(height: 24),
        if (n.props.isEmpty)
          const Text('(no diagnostic properties)')
        else
          ...n.props.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(p, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              )),
      ],
    );
  }
}
