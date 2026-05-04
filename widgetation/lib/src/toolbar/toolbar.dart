import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../config.dart';
import '../state/edits_store.dart';
import '../state/widgetation_store.dart';
import '../theme.dart';
import 'toolbar_button.dart';
import 'toolbar_icons.dart';

/// Floating control surface mounted by [Widgetation] in edit mode. Starts
/// as a 44×44 dark circle (collapsed); tap expands to a horizontal pill of
/// control buttons. Tap the close button to collapse again. Tap the gear
/// to surface a status popup via [OverlayPortal].
class WidgetationToolbar extends StatefulWidget {
  final AlignmentGeometry alignment;
  final WidgetationConfig config;

  // Live state from the host widget.
  final bool serverRunning;
  final bool viewerConnected;

  // Callbacks.
  final VoidCallback onCopyEdits;
  final VoidCallback onDeleteEdits;
  final VoidCallback onToggleEditsHidden;
  final VoidCallback onToggleSettings;
  final ValueChanged<bool> onExpandedChanged;

  const WidgetationToolbar({
    super.key,
    required this.alignment,
    required this.config,
    required this.serverRunning,
    required this.viewerConnected,
    required this.onCopyEdits,
    required this.onDeleteEdits,
    required this.onToggleEditsHidden,
    required this.onToggleSettings,
    required this.onExpandedChanged,
  });

  @override
  State<WidgetationToolbar> createState() => _WidgetationToolbarState();
}

class _WidgetationToolbarState extends State<WidgetationToolbar>
    with SingleTickerProviderStateMixin {
  static const double _collapsedSize = 44;
  static const double _expandedWidth = 229;
  static const double _expandedHeight = 44;

  late final AnimationController _ctrl;
  late final Animation<double> _widthT;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 280),
    );
    _widthT = CurvedAnimation(
      parent: _ctrl,
      curve: const _OvershootCurve(1.2),
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _expand() {
    _ctrl.forward();
    widget.onExpandedChanged(true);
  }

  void _collapse() {
    _ctrl.reverse();
    widget.onExpandedChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: widget.alignment,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final wt = _widthT.value;
              final ft = _ctrl.value;
              final theme = WidgetationTheme.of(context);
              final width = _collapsedSize + (_expandedWidth - _collapsedSize) * wt;
              final radius = _collapsedSize / 2;
              return Container(
                width: width,
                height: _expandedHeight,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: [
                    BoxShadow(blurRadius: 8, offset: const Offset(0, 2), color: theme.shadow),
                    BoxShadow(blurRadius: 16, offset: const Offset(0, 4), color: theme.shadow),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: (1.0 - ft / 0.35).clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: ft > 0.1,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: ft < 0.1 ? _expand : null,
                              child: SizedBox(
                                width: _collapsedSize,
                                height: _collapsedSize,
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CustomPaint(
                                      painter: ToolbarIconPainter(
                                        icon: ToolbarIcon.listSparkle,
                                        color: theme.onSurface,
                                        strokeWidth: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      OverflowBox(
                        minWidth: _expandedWidth,
                        maxWidth: _expandedWidth,
                        minHeight: _expandedHeight,
                        maxHeight: _expandedHeight,
                        child: IgnorePointer(
                          ignoring: ft < 0.6,
                          child: StoreBuilder<EditsStore, EditsState>(
                            builder: (context, edits) => _ControlsRow(
                              t: ft,
                              hidden: edits.hidden,
                              hasEdits: edits.edits.isNotEmpty,
                              onToggleHidden: widget.onToggleEditsHidden,
                              onCopy: widget.onCopyEdits,
                              onDelete: widget.onDeleteEdits,
                              onSettings: widget.onToggleSettings,
                              onClose: _collapse,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Mild back-easing: overshoots by ~5% near the end (vs ~10% for the
// stock easeOutBack). Tuned for a barely-there bounce on toolbar open.
class _OvershootCurve extends Curve {
  final double overshoot;
  const _OvershootCurve(this.overshoot);
  @override
  double transformInternal(double t) {
    final f = t - 1;
    return 1 + (overshoot + 1) * f * f * f + overshoot * f * f;
  }
}

class _ControlsRow extends StatelessWidget {
  final double t;
  final bool hidden;
  final bool hasEdits;
  final VoidCallback onToggleHidden;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onSettings;
  final VoidCallback onClose;

  const _ControlsRow({
    required this.t,
    required this.hidden,
    required this.hasEdits,
    required this.onToggleHidden,
    required this.onCopy,
    required this.onDelete,
    required this.onSettings,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      ToolbarControlButton(icon: ToolbarIcon.duplicate, onTap: hasEdits ? onCopy : null),
      ToolbarControlButton(icon: ToolbarIcon.trash, onTap: hasEdits ? onDelete : null),
      ToolbarControlButton(icon: ToolbarIcon.eye, active: hidden, onTap: onToggleHidden),
      ToolbarControlButton(icon: ToolbarIcon.settings, onTap: onSettings),
      const ToolbarDivider(),
      ToolbarControlButton(icon: ToolbarIcon.close, onTap: onClose),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < children.length; i++) _stagger(i, children.length, children[i]),
        ],
      ),
    );
  }

  // Each child fades + drifts up over a sliding window so the controls
  // cascade in left-to-right after the pill has finished widening.
  Widget _stagger(int i, int total, Widget child) {
    const startBase = 0.45;
    const startSpread = 0.15;
    const window = 0.4;
    const maxBlur = 4.0;
    // Blur clears over a tighter window so the icon snaps sharp slightly
    // before the fade finishes — gives the entrance a "lead-in" feel.
    const blurWindowFactor = 0.75;
    final start = startBase + (i / (total - 1)) * startSpread;
    final a = ((t - start) / window).clamp(0.0, 1.0);
    final blurA = ((t - start) / (window * blurWindowFactor)).clamp(0.0, 1.0);
    final translated = Transform.translate(
      offset: Offset(0, (1 - a) * 4),
      child: child,
    );
    // Skip the filter once it's resolved — ImageFiltered isn't free.
    final blurred = blurA >= 1.0
        ? translated
        : ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: maxBlur * (1 - blurA),
              sigmaY: maxBlur * (1 - blurA),
              tileMode: TileMode.decal,
            ),
            child: translated,
          );
    return Opacity(opacity: a, child: blurred);
  }
}
