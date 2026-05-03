import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class ConnectorsPanel extends StatelessWidget {
  const ConnectorsPanel({super.key});

  static const _connectors = [
    ConnectorEntry('GitHub', Icons.code, AppColors.success, 'Connected'),
    ConnectorEntry('Linear', Icons.linear_scale, AppColors.success, 'Connected'),
    ConnectorEntry('Slack', Icons.tag, AppColors.success, 'Connected'),
    ConnectorEntry('Google Drive', Icons.cloud_outlined, AppColors.warning, 'Re-auth'),
    ConnectorEntry('Notion', Icons.menu_book_outlined, AppColors.mutedSoft, 'Add'),
  ];

  @override
  Widget build(BuildContext context) {
    return OutlinedCreamCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Connectors', style: AppType.titleMd)),
              Text(
                '4 of 12',
                style: AppType.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final c in _connectors) ConnectorTile(entry: c),
          const SizedBox(height: AppSpacing.sm),
          const TextLink(label: 'Browse all connectors'),
        ],
      ),
    );
  }
}

class ConnectorEntry {
  final String name;
  final IconData icon;
  final Color statusColor;
  final String statusLabel;
  const ConnectorEntry(
    this.name,
    this.icon,
    this.statusColor,
    this.statusLabel,
  );
}

class ConnectorTile extends StatelessWidget {
  final ConnectorEntry entry;
  const ConnectorTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(entry.icon, size: 16, color: AppColors.ink),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(entry.name, style: AppType.bodySm)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusDot(color: entry.statusColor),
              const SizedBox(width: 6),
              Text(
                entry.statusLabel,
                style: AppType.caption.copyWith(color: entry.statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
