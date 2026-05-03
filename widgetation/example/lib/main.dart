import 'package:flutter/material.dart';
import 'package:widgetation/widgetation.dart';

import 'dashboard/dashboard_page.dart';
import 'design/tokens.dart';

void main() {
  runApp(
    const Widgetation(
      config: WidgetationConfig(name: 'widgetation example', fps: 8),
      child: ExampleApp(),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'widgetation example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.canvas,
        ),
        textTheme: const TextTheme(
          bodyMedium: AppType.bodyMd,
          bodySmall: AppType.bodySm,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
