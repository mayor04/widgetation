import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class UsagePanel extends StatelessWidget {
  const UsagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan usage',
                      style: AppType.titleMd.copyWith(color: AppColors.onDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Resets May 31',
                      style: AppType.caption.copyWith(color: AppColors.onDarkSoft),
                    ),
                  ],
                ),
              ),
              BadgePill.coral('Team'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _UsageBar(
            label: 'Messages',
            current: '14,820',
            limit: '20,000',
            progress: 0.74,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          const _UsageBar(
            label: 'Tokens (input + output)',
            current: '4.2M',
            limit: '10M',
            progress: 0.42,
            color: AppColors.accentTeal,
          ),
          const SizedBox(height: AppSpacing.md),
          const _UsageBar(
            label: 'Connector calls',
            current: '912',
            limit: '5,000',
            progress: 0.18,
            color: AppColors.accentAmber,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkElevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upgrade to Enterprise',
                        style: AppType.titleSm.copyWith(color: AppColors.onDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '5x the limits + SSO',
                        style: AppType.caption.copyWith(color: AppColors.onDarkSoft),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.onDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final String current;
  final String limit;
  final double progress;
  final Color color;
  const _UsageBar({
    required this.label,
    required this.current,
    required this.limit,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppType.caption.copyWith(color: AppColors.onDarkSoft),
              ),
            ),
            Text(
              '$current / $limit',
              style: AppType.caption.copyWith(color: AppColors.onDark),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Stack(
            children: [
              Container(
                height: 6,
                color: AppColors.surfaceDarkElevated,
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0, 1),
                child: Container(
                  height: 6,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
