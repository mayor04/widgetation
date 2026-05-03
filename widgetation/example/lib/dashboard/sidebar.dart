import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class DashboardSidebar extends StatelessWidget {
  final String activeKey;
  const DashboardSidebar({super.key, this.activeKey = 'overview'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.surfaceSoft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SidebarBrand(),
          const SizedBox(height: AppSpacing.xl),
          const _WorkspaceChip(),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: _SidebarNav(activeKey: activeKey)),
          const _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          const SpikeMark(size: 16),
          const SizedBox(width: 8),
          Text('Claude', style: AppType.titleMd.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  const _WorkspaceChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Helvetica Neue',
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anthropic', style: AppType.titleSm),
                Text('Team plan', style: AppType.caption.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          const Icon(Icons.unfold_more, size: 16, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _SidebarNav extends StatelessWidget {
  final String activeKey;
  const _SidebarNav({required this.activeKey});

  static const _primary = [
    SidebarItem('overview', Icons.dashboard_outlined, 'Overview'),
    SidebarItem('chats', Icons.chat_bubble_outline, 'Chats', badge: '24'),
    SidebarItem('projects', Icons.folder_outlined, 'Projects'),
    SidebarItem('artifacts', Icons.collections_bookmark_outlined, 'Artifacts'),
    SidebarItem('agents', Icons.smart_toy_outlined, 'Agents', isNew: true),
  ];

  static const _secondary = [
    SidebarItem('connectors', Icons.hub_outlined, 'Connectors'),
    SidebarItem('usage', Icons.show_chart, 'Usage'),
    SidebarItem('settings', Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _NavGroupLabel('Workspace'),
          for (final i in _primary) SidebarNavItem(item: i, active: i.key == activeKey),
          const SizedBox(height: AppSpacing.lg),
          const _NavGroupLabel('Manage'),
          for (final i in _secondary) SidebarNavItem(item: i, active: i.key == activeKey),
        ],
      ),
    );
  }
}

class _NavGroupLabel extends StatelessWidget {
  final String label;
  const _NavGroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppType.captionUppercase.copyWith(color: AppColors.mutedSoft),
      ),
    );
  }
}

class SidebarItem {
  final String key;
  final IconData icon;
  final String label;
  final String? badge;
  final bool isNew;
  const SidebarItem(this.key, this.icon, this.label, {this.badge, this.isNew = false});
}

class SidebarNavItem extends StatelessWidget {
  final SidebarItem item;
  final bool active;
  const SidebarNavItem({super.key, required this.item, required this.active});

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.ink : AppColors.body;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceCard : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: AppType.bodySm.copyWith(
                color: fg,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          if (item.isNew) BadgePill.coral('NEW'),
          if (item.badge != null)
            Text(item.badge!, style: AppType.caption.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceCreamStrong,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: AppColors.surfaceDark, shape: BoxShape.circle),
            child: Center(
              child: Text('M', style: AppType.titleSm.copyWith(color: AppColors.onDark)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mayor', style: AppType.titleSm),
                Text(
                  'mayor@anthropic.com',
                  style: AppType.caption.copyWith(color: AppColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }
}
