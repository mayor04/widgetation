import 'package:flutter/material.dart';
import 'package:widgetation/widgetation.dart';

import 'dashboard/dashboard_page.dart';
import 'design/tokens.dart';

void main() {
  runApp(const Widgetation(child: ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'widgetation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.canvas,
          primary: AppColors.primary,
        ),
        textTheme: const TextTheme(
          bodyLarge: AppType.body,
          bodyMedium: AppType.body,
          bodySmall: AppType.caption,
          labelLarge: AppType.bodyStrong,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
