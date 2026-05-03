import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class KpiRow extends StatelessWidget {
  const KpiRow({super.key});

  static const _kpis = [
    KpiData(
      label: 'Active chats',
      value: '128',
      delta: '+12.4%',
      deltaUp: true,
      sparkline: [3, 5, 4, 6, 5, 7, 6, 8, 7, 9, 11, 10],
    ),
    KpiData(
      label: 'Tokens used',
      value: '4.2M',
      delta: '+3.1%',
      deltaUp: true,
      sparkline: [4, 6, 5, 7, 8, 6, 9, 8, 10, 9, 11, 12],
    ),
    KpiData(
      label: 'Avg. response time',
      value: '1.8s',
      delta: '-180ms',
      deltaUp: false,
      goodWhenDown: true,
      sparkline: [9, 8, 9, 7, 8, 6, 7, 5, 6, 5, 4, 5],
    ),
    KpiData(
      label: 'Connector calls',
      value: '912',
      delta: '+24',
      deltaUp: true,
      sparkline: [2, 3, 4, 3, 5, 6, 5, 7, 6, 8, 7, 9],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth < 640
            ? 1
            : constraints.maxWidth < 1000
                ? 2
                : 4;
        return _KpiGrid(columns: cols, kpis: _kpis);
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final int columns;
  final List<KpiData> kpis;
  const _KpiGrid({required this.columns, required this.kpis});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < kpis.length; i += columns) {
      final slice = kpis.sublist(i, (i + columns).clamp(0, kpis.length));
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.md),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < slice.length; j++) ...[
                  Expanded(child: KpiCard(data: slice[j])),
                  if (j < slice.length - 1)
                    const SizedBox(width: AppSpacing.md),
                ],
                for (var k = slice.length; k < columns; k++) ...[
                  const Expanded(child: SizedBox()),
                  if (k < columns - 1)
                    const SizedBox(width: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class KpiData {
  final String label;
  final String value;
  final String delta;
  final bool deltaUp;
  final bool goodWhenDown;
  final List<double> sparkline;
  const KpiData({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaUp,
    this.goodWhenDown = false,
    required this.sparkline,
  });

  bool get deltaIsGood => goodWhenDown ? !deltaUp : deltaUp;
}

class KpiCard extends StatelessWidget {
  final KpiData data;
  const KpiCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final goodColor = AppColors.success;
    final badColor = AppColors.error;
    final deltaColor = data.deltaIsGood ? goodColor : badColor;

    return OutlinedCreamCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            style: AppType.caption.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(data.value, style: AppType.displaySm),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                data.deltaUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: deltaColor,
              ),
              const SizedBox(width: 4),
              Text(
                data.delta,
                style: AppType.caption.copyWith(color: deltaColor),
              ),
              const SizedBox(width: 6),
              Text(
                'vs last week',
                style: AppType.caption.copyWith(color: AppColors.mutedSoft),
              ),
              const Spacer(),
              SizedBox(
                width: 80,
                height: 28,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    points: data.sparkline,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final minV = points.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);
    final dx = size.width / (points.length - 1).clamp(1, 999);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height - ((points[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, stroke);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fill = Paint()..color = color.withValues(alpha: 0.10);
    canvas.drawPath(fillPath, fill);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
