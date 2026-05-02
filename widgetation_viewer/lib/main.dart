import 'package:flutter/material.dart';

import 'src/inspector_page.dart';

void main() {
  runApp(const WidgetationViewerApp());
}

class WidgetationViewerApp extends StatelessWidget {
  const WidgetationViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widgetation Viewer',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const InspectorPage(),
    );
  }
}
