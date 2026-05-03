import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class ConversationsCard extends StatelessWidget {
  const ConversationsCard({super.key});

  static const _rows = [
    ConversationRow(
      title: 'Refactor checkout flow into smaller components',
      project: 'shopfront-web',
      model: 'Sonnet 4.6',
      messages: 24,
      updated: '2 min ago',
      status: ChatStatus.live,
    ),
    ConversationRow(
      title: 'Draft Q2 board update memo',
      project: 'leadership',
      model: 'Opus 4.7',
      messages: 8,
      updated: '14 min ago',
      status: ChatStatus.idle,
    ),
    ConversationRow(
      title: 'Investigate flaky integration test in billing',
      project: 'platform',
      model: 'Sonnet 4.6',
      messages: 41,
      updated: '1 hr ago',
      status: ChatStatus.idle,
    ),
    ConversationRow(
      title: 'Compare three contract redlines from legal',
      project: 'legal',
      model: 'Opus 4.7',
      messages: 12,
      updated: '3 hr ago',
      status: ChatStatus.archived,
    ),
    ConversationRow(
      title: 'Translate landing page copy to French + German',
      project: 'marketing',
      model: 'Haiku 4.5',
      messages: 6,
      updated: 'Yesterday',
      status: ChatStatus.idle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return OutlinedCreamCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ConversationsHeader(),
          for (var i = 0; i < _rows.length; i++) ...[
            ConversationRowTile(row: _rows[i]),
            if (i < _rows.length - 1)
              const Divider(
                color: AppColors.hairlineSoft,
                height: 1,
                thickness: 1,
              ),
          ],
        ],
      ),
    );
  }
}

class _ConversationsHeader extends StatelessWidget {
  const _ConversationsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent conversations', style: AppType.titleMd),
                const SizedBox(height: 2),
                Text(
                  'Across all your projects',
                  style: AppType.caption.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const _FilterTabs(),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  static const _tabs = ['All', 'Live', 'Archived'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            _FilterTab(label: _tabs[i], active: i == 0),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterTab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.canvas : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: active
            ? Border.all(color: AppColors.hairline)
            : null,
      ),
      child: Text(
        label,
        style: AppType.caption.copyWith(
          color: active ? AppColors.ink : AppColors.muted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum ChatStatus { live, idle, archived }

class ConversationRow {
  final String title;
  final String project;
  final String model;
  final int messages;
  final String updated;
  final ChatStatus status;
  const ConversationRow({
    required this.title,
    required this.project,
    required this.model,
    required this.messages,
    required this.updated,
    required this.status,
  });
}

class ConversationRowTile extends StatelessWidget {
  final ConversationRow row;
  const ConversationRowTile({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          ChatStatusBadge(status: row.status),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: AppType.titleSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      row.project,
                      style: AppType.caption.copyWith(color: AppColors.muted),
                    ),
                    _Dot(),
                    Text(
                      row.model,
                      style: AppType.caption.copyWith(color: AppColors.muted),
                    ),
                    _Dot(),
                    Text(
                      '${row.messages} messages',
                      style: AppType.caption.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            row.updated,
            style: AppType.caption.copyWith(color: AppColors.mutedSoft),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: AppColors.mutedSoft,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ChatStatusBadge extends StatelessWidget {
  final ChatStatus status;
  const ChatStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ChatStatus.live => (AppColors.success, 'Live'),
      ChatStatus.idle => (AppColors.accentAmber, 'Idle'),
      ChatStatus.archived => (AppColors.mutedSoft, 'Archived'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppType.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
