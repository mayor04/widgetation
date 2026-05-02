import 'package:flutter/material.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  runApp(
    const InspectorStreamer(
      config: WidgetationConfig(name: 'widgetation example', fps: 8),
      child: MaterialApp(home: Scaffold(body: Center(child: Text('hello')))),
    ),
  );
}
