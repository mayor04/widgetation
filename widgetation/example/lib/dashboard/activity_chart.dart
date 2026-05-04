import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class ActivityChartCard extends StatelessWidget {
  const ActivityChartCard({super.key});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _chats = <double>[42, 56, 48, 71, 64, 22, 18];
  static const _agents = <double>[12, 18, 16, 28, 32, 14, 9];

  @override
  Widget build(BuildContext context) {
    return OutlinedCreamCard(
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
                    Text('Activity this week', style: AppType.titleMd),
                    const SizedBox(height: 2),
                    Text(
                      'Chats and agent runs across the workspace',
                      style: AppType.caption.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Row(
                children: const [
                  _LegendDot(color: AppColors.primary, label: 'Chats'),
                  SizedBox(width: AppSpacing.md),
                  _LegendDot(color: AppColors.accentTeal, label: 'Agent runs'),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: _BarChart(days: _days, chats: _chats, agents: _agents),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatusDot(color: color),
        const SizedBox(width: 6),
        Text(label, style: AppType.caption.copyWith(color: AppColors.body)),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<String> days;
  final List<double> chats;
  final List<double> agents;
  const _BarChart({
    required this.days,
    required this.chats,
    required this.agents,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = [
      ...chats,
      ...agents,
    ].reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < days.length; i++) ...[
          Expanded(
            child: _BarGroup(
              day: days[i],
              chatHeight: chats[i] / maxV,
              agentHeight: agents[i] / maxV,
            ),
          ),
          if (i < days.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _BarGroup extends StatelessWidget {
  final String day;
  final double chatHeight;
  final double agentHeight;
  const _BarGroup({
    required this.day,
    required this.chatHeight,
    required this.agentHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _Bar(height: c.maxHeight * chatHeight, color: AppColors.primary)),
                const SizedBox(width: 4),
                Expanded(child: _Bar(height: c.maxHeight * agentHeight, color: AppColors.accentTeal)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: AppType.caption.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}
