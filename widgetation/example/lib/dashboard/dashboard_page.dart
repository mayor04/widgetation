import 'package:flutter/material.dart';

import '../design/tokens.dart';
import 'sections.dart';
import 'sidebar.dart';
import 'titlebar.dart';

/// Widgetation Studio — a desktop-style explainer app.
///
/// macOS chassis: titlebar with traffic lights at the top, translucent sidebar
/// on the left, scrollable detail pane on the right. Sidebar selection swaps
/// the section in the detail pane.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _active = 'overview';

  static const _titles = {
    'overview': ('Overview', 'widgetation'),
    'flow': ('How it works', 'widgetation'),
    'output': ('Clipboard output', 'widgetation'),
    'setup': ('Setup', 'widgetation'),
    'config': ('Configuration', 'widgetation'),
    'compatibility': ('Compatibility', 'widgetation'),
  };

  Widget _section() {
    switch (_active) {
      case 'flow':
        return const FlowSection();
      case 'output':
        return const OutputSection();
      case 'setup':
        return const SetupSection();
      case 'config':
        return const ConfigSection();
      case 'compatibility':
        return const CompatibilitySection();
      case 'overview':
      default:
        return const OverviewSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _titles[_active]!;
    return Scaffold(
      backgroundColor: AppColors.canvasParchment,
      body: Column(
        children: [
          WindowTitleBar(title: title, subtitle: subtitle),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSidebar(
                  activeKey: _active,
                  onSelect: (k) => setState(() => _active = k),
                ),
                Expanded(
                  child: Container(
                    color: AppColors.canvasParchment,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 880),
                          child: _section(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
