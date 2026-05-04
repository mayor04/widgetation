import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

/// macOS-style window titlebar — traffic lights left, centered title,
/// toolbar actions right. Sits above the sidebar and detail pane.
class WindowTitleBar extends StatelessWidget {
  final String title;
  final String subtitle;
  const WindowTitleBar({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.titlebar,
        border: Border(
          bottom: BorderSide(color: AppColors.hairline, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const _TrafficLights(),
          const SizedBox(width: 18),
          const _SidebarToggle(),
          const SizedBox(width: 8),
          const _NavArrow(icon: Icons.chevron_left, enabled: false),
          const _NavArrow(icon: Icons.chevron_right, enabled: false),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppType.windowTitle),
              const SizedBox(height: 1),
              Text(subtitle, style: AppType.caption),
            ],
          ),
          const Spacer(),
          const _ToolbarIcon(Icons.search, tooltip: 'Search'),
          const SizedBox(width: 4),
          const _ToolbarIcon(Icons.tune, tooltip: 'Filters'),
          const SizedBox(width: 4),
          const _ToolbarIcon(Icons.ios_share, tooltip: 'Share'),
          const SizedBox(width: 12),
          const ButtonPrimary(label: 'Annotate', icon: Icons.adjust),
        ],
      ),
    );
  }
}

class _TrafficLights extends StatelessWidget {
  const _TrafficLights();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _TrafficDot(color: AppColors.trafficClose),
        SizedBox(width: 8),
        _TrafficDot(color: AppColors.trafficMin),
        SizedBox(width: 8),
        _TrafficDot(color: AppColors.trafficMax),
      ],
    );
  }
}

class _TrafficDot extends StatelessWidget {
  final Color color;
  const _TrafficDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.10), width: 0.5),
      ),
    );
  }
}

class _SidebarToggle extends StatelessWidget {
  const _SidebarToggle();

  @override
  Widget build(BuildContext context) {
    return const _ToolbarIcon(Icons.view_sidebar_outlined, tooltip: 'Toggle sidebar');
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  const _NavArrow({required this.icon, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.ink : AppColors.inkMuted32;
    return SizedBox(
      width: 28,
      height: 28,
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  const _ToolbarIcon(this.icon, {required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 16, color: AppColors.inkMuted80),
      ),
    );
  }
}
