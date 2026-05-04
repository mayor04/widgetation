import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

/// Header used at the top of every detail-pane section.
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(),
            style: AppType.captionStrong.copyWith(color: AppColors.primary)),
        const SizedBox(height: 6),
        Text(title, style: AppType.titleXl),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(subtitle,
              style: AppType.body.copyWith(color: AppColors.inkMuted48)),
        ),
      ],
    );
  }
}

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Overview',
          title: 'Visual feedback. For agents.',
          subtitle:
              'Widgetation turns UI annotations into structured context that AI coding agents '
              'can act on. Click any widget, attach a note, and copy formatted markdown — file '
              'paths and line numbers are already attached.',
        ),
        const SizedBox(height: AppSpacing.lg),
        const _AppPreview(),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: _Stat(label: 'Lines of setup', value: '2')),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _Stat(label: 'Release-mode cost', value: '0 KB')),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _Stat(label: 'Supported targets', value: '6')),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: _Stat(label: 'License', value: 'MIT')),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppType.caption),
          const SizedBox(height: 4),
          Text(value, style: AppType.titleLg),
        ],
      ),
    );
  }
}

/// Mini "host app" preview with the floating ◎ pinned to the bottom-right.
class _AppPreview extends StatelessWidget {
  const _AppPreview();

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          height: 260,
          color: AppColors.canvasParchment,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.hairlineSoft),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('your_app.dart', style: AppType.caption),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Welcome back', style: AppType.titleLg),
                      const SizedBox(height: 2),
                      Text('Pick up where you left off.', style: AppType.body),
                      const SizedBox(height: AppSpacing.md),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.canvasParchment,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.image_outlined,
                                    size: 14, color: AppColors.ink),
                                const SizedBox(width: 8),
                                Text('HeroBanner', style: AppType.bodyStrong),
                                const SizedBox(width: 8),
                                Text('lib/widgets/hero.dart:42',
                                    style: AppType.caption),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Text(
                                'Selected',
                                style: AppType.captionStrong
                                    .copyWith(color: AppColors.onPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 14,
                bottom: 14,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceTile3,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x38000000),
                        blurRadius: 16,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: WidgetationMark(size: 20, color: AppColors.onDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowSection extends StatelessWidget {
  const FlowSection({super.key});

  static const _steps = [
    _Step('01', 'Activate',
        'Tap the floating ◎ in the bottom corner of any debug build.'),
    _Step('02', 'Hover',
        'Move the cursor across your UI — widget names surface live.'),
    _Step('03', 'Click',
        'Pick a single widget, or marquee-drag to group several.'),
    _Step('04', 'Annotate', 'Type plain-English feedback — like briefing a teammate.'),
    _Step('05', 'Copy', 'Tap ⧉ — notes bundle into markdown with file + line.'),
    _Step('06', 'Paste', 'Drop into Claude Code, Codex, or Cursor.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'How it works',
          title: 'Six taps. Real context.',
          subtitle:
              'Widgetation hooks Flutter\'s element tree. The agent doesn\'t see screenshots — '
              'it sees widget types, file paths, and line numbers next to your note.',
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth < 520 ? 1 : c.maxWidth < 820 ? 2 : 3;
            return _Grid(columns: cols, items: _steps.map((s) => _StepCard(step: s)).toList());
          },
        ),
      ],
    );
  }
}

class _Step {
  final String n;
  final String title;
  final String body;
  const _Step(this.n, this.title, this.body);
}

class _StepCard extends StatelessWidget {
  final _Step step;
  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(step.n,
              style: AppType.code.copyWith(color: AppColors.primary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(step.title, style: AppType.titleMd),
          const SizedBox(height: 2),
          Text(step.body, style: AppType.body),
        ],
      ),
    );
  }
}

class OutputSection extends StatelessWidget {
  const OutputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Clipboard output',
          title: 'Markdown, not screenshots.',
          subtitle:
              'When you copy, widgetation emits structured markdown. Each note carries the '
              'widget type, source file, and line number — exactly what an agent needs to '
              'edit the right code.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _Clipboard(),
      ],
    );
  }
}

class _Clipboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceTile1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTile3,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Text('Clipboard · 1.2 KB',
                    style: AppType.caption.copyWith(color: AppColors.codeComment)),
                const Spacer(),
                Icon(Icons.copy, size: 12, color: AppColors.codeComment),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('### **Page Feedback List**',
                    style: AppType.code.copyWith(color: AppColors.codeKeyword)),
                const SizedBox(height: 8),
                _entry('1.', 'Text ("Welcome back")', 'lib/screens/home_page.dart:42',
                    'larger and centered on mobile'),
                const SizedBox(height: 8),
                _entry('2.', 'ElevatedButton +2',
                    'lib/screens/home_page.dart:88, lib/widgets/cta.dart:14',
                    'align horizontally with equal spacing'),
                const SizedBox(height: 8),
                _entry('3.', 'Card · "Recent activity"',
                    'lib/dashboard/activity_card.dart:18',
                    'soften the border, drop the shadow'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _entry(String n, String head, String src, String fb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(n, style: AppType.code.copyWith(color: AppColors.codePunct)),
          const SizedBox(width: 6),
          Text(head, style: AppType.code.copyWith(color: AppColors.codeIdent)),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(style: AppType.code, children: [
                  TextSpan(
                      text: 'Source: ',
                      style: AppType.code.copyWith(color: AppColors.codeComment)),
                  TextSpan(
                      text: src,
                      style: AppType.code.copyWith(color: AppColors.codeString)),
                ]),
              ),
              RichText(
                text: TextSpan(style: AppType.code, children: [
                  TextSpan(
                      text: 'Feedback: ',
                      style: AppType.code.copyWith(color: AppColors.codeComment)),
                  TextSpan(
                      text: fb,
                      style: AppType.code.copyWith(color: AppColors.codeText)),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SetupSection extends StatelessWidget {
  const SetupSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Setup',
          title: 'Two steps.',
          subtitle:
              'Add the dependency, wrap your root widget. Widgetation only mounts in debug '
              'and profile builds — release is a true no-op.',
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 700) {
              return Column(children: [_pubspec(), const SizedBox(height: AppSpacing.sm), _main()]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: _pubspec()),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _main()),
            ]);
          },
        ),
      ],
    );
  }

  Widget _pubspec() => _CodeCard(
        title: 'pubspec.yaml',
        spans: [
          [_T('dependencies:', AppColors.codeKeyword)],
          [_T('  widgetation: ', AppColors.codeIdent), _T('^0.1.0', AppColors.codeString)],
          [],
          [_T('# then run', AppColors.codeComment)],
          [_T('flutter pub get', AppColors.codeText)],
        ],
      );

  Widget _main() => _CodeCard(
        title: 'lib/main.dart',
        spans: [
          [
            _T('import ', AppColors.codeKeyword),
            _T("'package:widgetation/widgetation.dart'", AppColors.codeString),
            _T(';', AppColors.codePunct),
          ],
          [],
          [
            _T('void ', AppColors.codeKeyword),
            _T('main', AppColors.codeIdent),
            _T('() {', AppColors.codeText),
          ],
          [
            _T('  runApp(', AppColors.codeText),
            _T('const ', AppColors.codeKeyword),
            _T('Widgetation', AppColors.codeIdent),
            _T('(child: ', AppColors.codeText),
            _T('MyApp', AppColors.codeIdent),
            _T('()));', AppColors.codeText),
          ],
          [_T('}', AppColors.codeText)],
        ],
      );
}

class ConfigSection extends StatelessWidget {
  const ConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Configuration',
          title: 'Sensible defaults.',
          subtitle:
              'WidgetationConfig controls runtime behavior, where the floating button sits, and a '
              'kill switch. Most projects never need to touch it.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Panel(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: const [
              _Row(name: 'mode', type: 'WidgetationMode', value: 'edit',
                  desc: 'Render the floating select button. Use .none to disable at runtime.'),
              Hairline(),
              _Row(name: 'selectButtonAlignment', type: 'AlignmentGeometry', value: 'bottomRight',
                  desc: 'Where the floating reticle sits while in edit mode.'),
              Hairline(),
              _Row(name: 'enabled', type: 'bool', value: 'true',
                  desc: 'Kill switch. When false, Widgetation no-ops regardless of mode.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String name;
  final String type;
  final String value;
  final String desc;
  const _Row({required this.name, required this.type, required this.value, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppType.code.copyWith(color: AppColors.ink, fontSize: 12)),
                const SizedBox(height: 2),
                Text(type, style: AppType.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc, style: AppType.body),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.canvasParchment,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.hairlineSoft),
            ),
            child: Text(value,
                style: AppType.code.copyWith(color: AppColors.primary, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class CompatibilitySection extends StatelessWidget {
  const CompatibilitySection({super.key});

  static const _items = [
    _Plat(Icons.apple, 'macOS', 'desktop'),
    _Plat(Icons.phone_iphone, 'iOS', 'phone & tablet'),
    _Plat(Icons.android, 'Android', 'phone & tablet'),
    _Plat(Icons.window, 'Windows', 'desktop'),
    _Plat(Icons.computer, 'Linux', 'desktop'),
    _Plat(Icons.public, 'Web', 'browser'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Compatibility',
          title: 'Everywhere Flutter runs.',
          subtitle:
              'Flutter ≥ 3.10 · Dart ≥ 3.11.1. Wrap once, ship to every surface — release builds '
              'never carry the overlay.',
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth < 520 ? 2 : c.maxWidth < 800 ? 3 : 6;
            return _Grid(
              columns: cols,
              items: _items.map((p) => _PlatCard(item: p)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _Plat {
  final IconData icon;
  final String name;
  final String hint;
  const _Plat(this.icon, this.name, this.hint);
}

class _PlatCard extends StatelessWidget {
  final _Plat item;
  const _PlatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 18, color: AppColors.ink),
          const SizedBox(height: 8),
          Text(item.name, style: AppType.titleMd),
          const SizedBox(height: 1),
          Text(item.hint, style: AppType.caption),
        ],
      ),
    );
  }
}

// --- shared helpers ---

class _Grid extends StatelessWidget {
  final int columns;
  final List<Widget> items;
  const _Grid({required this.columns, required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += columns) {
      final slice = items.sublist(i, (i + columns).clamp(0, items.length));
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.sm),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < slice.length; j++) ...[
                  Expanded(child: slice[j]),
                  if (j < slice.length - 1) const SizedBox(width: AppSpacing.sm),
                ],
                for (var k = slice.length; k < columns; k++) ...[
                  const Expanded(child: SizedBox()),
                  if (k < columns - 1) const SizedBox(width: AppSpacing.sm),
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

class _T {
  final String text;
  final Color color;
  const _T(this.text, this.color);
}

class _CodeCard extends StatelessWidget {
  final String title;
  final List<List<_T>> spans;
  const _CodeCard({required this.title, required this.spans});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceTile1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTile3,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined,
                    size: 12, color: AppColors.codeComment),
                const SizedBox(width: 6),
                Text(title,
                    style: AppType.code.copyWith(color: AppColors.codeText)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in spans)
                  RichText(
                    text: TextSpan(style: AppType.code, children: [
                      for (final t in line)
                        TextSpan(
                          text: t.text,
                          style: AppType.code.copyWith(color: t.color),
                        ),
                      if (line.isEmpty) const TextSpan(text: ' '),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
