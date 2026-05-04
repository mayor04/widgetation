import '../tree_node.dart';

/// Build the heading text for the chat box / hover popover.
///
/// Format: `<type>` — and if the node carries a recognisable text
/// property (e.g. `data` or `text`), append a quoted excerpt:
/// `Text "How you use it"`. Long strings are truncated.
String formatNodeLabel(TreeNode node) {
  final base = node.nearestWidget?.isEmpty ?? false ? '' : node.nearestWidget!;
  final text = _extractText(node);
  if (text == null) return '$base(${node.type})';
  final trimmed = text.length > 32 ? '${text.substring(0, 32)}…' : text;
  return '${node.type} ($trimmed)';
}

/// Heading text when a draft covers multiple nodes from a marquee
/// selection. Single-node case delegates to [formatNodeLabel] so behaviour
/// stays identical for tap selections.
String formatMultiNodeLabel(List<TreeNode> nodes) {
  if (nodes.isEmpty) return '';
  if (nodes.length == 1) return formatNodeLabel(nodes.first);
  return '${formatNodeLabel(nodes.first)} +${nodes.length - 1}';
}

String? _extractText(TreeNode node) {
  for (final key in const ['data', 'text', 'label', 'title']) {
    final v = node.widgetProperties[key];
    if (v == null || v.isEmpty) continue;
    return v;
  }
  return null;
}
