import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class SidebarSection {
  final String key;
  final IconData icon;
  final String label;
  final String? badge;
  const SidebarSection(this.key, this.icon, this.label, {this.badge});
}

/// Translucent macOS-style sidebar with the widgetation reticle in the header,
/// grouped section list, and a quiet status row at the bottom.
class AppSidebar extends StatelessWidget {
  final String activeKey;
  final ValueChanged<String> onSelect;
  const AppSidebar({super.key, required this.activeKey, required this.onSelect});

  static const _learn = [
    SidebarSection('overview', Icons.auto_awesome_outlined, 'Overview'),
    SidebarSection('flow', Icons.adjust, 'How it works'),
    SidebarSection('output', Icons.code, 'Clipboard output'),
  ];

  static const _build = [
    SidebarSection('setup', Icons.terminal, 'Setup'),
    SidebarSection('config', Icons.tune, 'Configuration'),
    SidebarSection('compatibility', Icons.devices_outlined, 'Compatibility'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(color: AppColors.hairline, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Brand(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GroupHeader('Learn'),
                  for (final s in _learn)
                    _SidebarRow(
                      section: s,
                      active: s.key == activeKey,
                      onTap: () => onSelect(s.key),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  const _GroupHeader('Build'),
                  for (final s in _build)
                    _SidebarRow(
                      section: s,
                      active: s.key == activeKey,
                      onTap: () => onSelect(s.key),
                    ),
                ],
              ),
            ),
          ),
          const _StatusRow(),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Row(
        children: [
          const WidgetationMark(size: 14, color: AppColors.ink),
          const SizedBox(width: 8),
          Text('widgetation', style: AppType.bodyStrong),
          const Spacer(),
          Text('0.1.0', style: AppType.caption),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Text(label.toUpperCase(), style: AppType.sidebarGroup),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  final SidebarSection section;
  final bool active;
  final VoidCallback onTap;
  const _SidebarRow({required this.section, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(
              section.icon,
              size: 14,
              color: active ? AppColors.onPrimary : AppColors.inkMuted80,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                section.label,
                style: AppType.sidebar.copyWith(
                  color: active ? AppColors.onPrimary : AppColors.ink,
                ),
              ),
            ),
            if (section.badge != null)
              Text(
                section.badge!,
                style: AppType.caption.copyWith(
                  color: active ? AppColors.onPrimary : AppColors.inkMuted48,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairlineSoft, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF34C759),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Debug overlay attached', style: AppType.caption),
          ),
        ],
      ),
    );
  }
}
