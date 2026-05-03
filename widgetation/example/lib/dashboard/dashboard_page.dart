import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';
import 'activity_chart.dart';
import 'connectors_panel.dart';
import 'conversations_table.dart';
import 'kpi_row.dart';
import 'sidebar.dart';
import 'topbar.dart';
import 'usage_panel.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            return Row(
              children: [
                if (!compact) const DashboardSidebar(activeKey: 'overview'),
                const Expanded(child: _DashboardMain()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardMain extends StatelessWidget {
  const _DashboardMain();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        DashboardTopBar(),
        Expanded(child: _DashboardScroll()),
      ],
    );
  }
}

class _DashboardScroll extends StatelessWidget {
  const _DashboardScroll();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _GreetingStrip(),
          SizedBox(height: AppSpacing.xl),
          KpiRow(),
          SizedBox(height: AppSpacing.xl),
          _MainGrid(),
        ],
      ),
    );
  }
}

class _GreetingStrip extends StatelessWidget {
  const _GreetingStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionEyebrow(label: 'Friday, May 2'),
              const SizedBox(height: AppSpacing.sm),
              Text('Good morning, Mayor.', style: AppType.displayMd),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Here is what your workspace did while you were away.',
                style: AppType.bodyMd,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Row(
          children: const [
            ButtonSecondary(label: 'Invite teammate'),
            SizedBox(width: AppSpacing.sm),
            ButtonPrimary(label: 'Start a chat'),
          ],
        ),
      ],
    );
  }
}

class _MainGrid extends StatelessWidget {
  const _MainGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 1100;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ActivityChartCard(),
              SizedBox(height: AppSpacing.lg),
              ConversationsCard(),
              SizedBox(height: AppSpacing.lg),
              UsagePanel(),
              SizedBox(height: AppSpacing.lg),
              ConnectorsPanel(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  ActivityChartCard(),
                  SizedBox(height: AppSpacing.lg),
                  ConversationsCard(),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  UsagePanel(),
                  SizedBox(height: AppSpacing.lg),
                  ConnectorsPanel(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
