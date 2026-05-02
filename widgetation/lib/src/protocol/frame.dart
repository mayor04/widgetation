import 'dart:convert';
import 'dart:typed_data';

import 'messages.dart';
import 'tree_node.dart';

class ScreenSize {
  final double w, h;
  const ScreenSize(this.w, this.h);
}

class Frame extends ServerMessage {
  final int timestamp;
  final double devicePixelRatio;
  final ScreenSize screenSize;
  final Uint8List png;
  final List<TreeNode> tree;

  Frame({
    required this.timestamp,
    required this.devicePixelRatio,
    required this.screenSize,
    required this.png,
    required this.tree,
  });

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'frame',
        'timestamp': timestamp,
        'screenshot': base64Encode(png),
        'devicePixelRatio': devicePixelRatio,
        'screenSize': {'w': screenSize.w, 'h': screenSize.h},
        'tree': tree.map((n) => n.toJson()).toList(),
      };
}
