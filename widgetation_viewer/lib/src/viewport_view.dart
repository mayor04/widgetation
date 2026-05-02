import 'package:flutter/material.dart';

import 'frame.dart' as proto;

/// Displays the streamed PNG inside a "device frame" border.
///
/// Hover-to-inspect overlay arrives in a subsequent commit.
class ViewportView extends StatelessWidget {
  final proto.InspectorFrame? frame;

  const ViewportView({super.key, required this.frame});

  @override
  Widget build(BuildContext context) {
    final f = frame;
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: f == null ? _placeholder(context) : _viewport(f),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Text(
      'Waiting for frames…\n\nConnect to a running widgetation streamer\nusing the Host/Port fields above.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _viewport(proto.InspectorFrame f) {
    final aspect = f.logicalSize.width / f.logicalSize.height;
    return AspectRatio(
      aspectRatio: aspect == 0 ? 0.5 : aspect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 8),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(blurRadius: 24, color: Colors.black54),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            f.png,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
