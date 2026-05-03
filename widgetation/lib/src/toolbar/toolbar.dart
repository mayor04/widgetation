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
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _t = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuint);
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
            animation: _t,
            builder: (context, _) {
              final t = _t.value;
              final theme = WidgetationTheme.of(context);
              final width = _collapsedSize + (_expandedWidth - _collapsedSize) * t;
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
                        // Collapsed wand glyph — visible while t < ~0.5.
                        Opacity(
                          opacity: (1.0 - t * 2).clamp(0.0, 1.0),
                          child: IgnorePointer(
                            ignoring: t > 0.1,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: t < 0.1 ? _expand : null,
                              child: SizedBox(
                                width: _collapsedSize,
                                height: _collapsedSize,
                                child: CustomPaint(
                                  painter: ToolbarIconPainter(
                                    icon: ToolbarIcon.listSparkle,
                                    color: theme.onSurface,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Expanded controls — fade in past the midpoint.
                        Opacity(
                          opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
                          child: IgnorePointer(
                            ignoring: t < 0.9,
                            child: StoreBuilder<EditsStore, EditsState>(
                              builder: (context, edits) => _ControlsRow(
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

class _ControlsRow extends StatelessWidget {
  final bool hidden;
  final bool hasEdits;
  final VoidCallback onToggleHidden;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onSettings;
  final VoidCallback onClose;

  const _ControlsRow({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToolbarControlButton(
            icon: ToolbarIcon.duplicate,
            onTap: hasEdits ? onCopy : null,
          ),
          ToolbarControlButton(
            icon: ToolbarIcon.trash,
            onTap: hasEdits ? onDelete : null,
          ),
          ToolbarControlButton(
            icon: ToolbarIcon.eye,
            active: hidden,
            onTap: onToggleHidden,
          ),
          ToolbarControlButton(
            icon: ToolbarIcon.settings,
            onTap: onSettings,
          ),
          const ToolbarDivider(),
          ToolbarControlButton(
            icon: ToolbarIcon.close,
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}
