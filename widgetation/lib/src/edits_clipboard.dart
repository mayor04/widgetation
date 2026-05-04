import 'edits/edit_label.dart';
import 'state/edits_store.dart';

String formatEditsForClipboard(List<Edit> edits) {
  final sb = StringBuffer('### **Page Feedback List**\n\n');
  for (final edit in edits) {
    final label = edit.nodes.isEmpty
        ? '(unknown)'
        : formatMultiNodeLabel(edit.nodes);
    final source = _formatEditSources(edit);
    sb.writeln('${edit.index}. $label');
    sb.writeln('Source: $source');
    sb.writeln('Feedback: ${edit.text}');
    sb.writeln();
  }
  return sb.toString().trimRight();
}

String _formatEditSources(Edit edit) {
  if (edit.nodes.isEmpty) return '(unknown)';
  final parts = <String>{};
  for (var i = 0; i < edit.nodes.length; i++) {
    final node = edit.nodes[i];
    final file = i < edit.files.length ? edit.files[i] : node.file;
    if (file == null) continue;
    parts.add('$file:${node.line ?? '?'}');
  }
  if (parts.isEmpty) return '(unknown)';
  return parts.join(', ');
}
