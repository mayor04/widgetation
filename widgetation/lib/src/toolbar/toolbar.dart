import 'package:flutter/widgets.dart';

import '../config.dart';
import '../state/selection_store.dart';
import '../state/widgetation_store.dart';
import 'status_popup.dart';
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
  final bool highlightsVisible;
  final bool serverRunning;
  final bool viewerConnected;

  // Callbacks.
  final VoidCallback onToggleHighlights;
  final VoidCallback onCopySelection;
  final VoidCallback onClearSelection;
  final ValueChanged<bool> onExpandedChanged;

  const WidgetationToolbar({
    super.key,
    required this.alignment,
    required this.config,
    required this.highlightsVisible,
    required this.serverRunning,
    required this.viewerConnected,
    required this.onToggleHighlights,
    required this.onCopySelection,
    required this.onClearSelection,
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
  final OverlayPortalController _popup = OverlayPortalController();

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
    if (_popup.isShowing) _popup.hide();
    _ctrl.reverse();
    widget.onExpandedChanged(false);
  }

  void _toggleSettings() {
    if (_popup.isShowing) {
      _popup.hide();
    } else {
      _popup.show();
    }
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
              final width = _collapsedSize + (_expandedWidth - _collapsedSize) * t;
              final radius = _collapsedSize / 2;
              return OverlayPortal(
                controller: _popup,
                overlayChildBuilder: (ctx) => ToolbarStatusPopup(
                  config: widget.config,
                  serverRunning: widget.serverRunning,
                  viewerConnected: widget.viewerConnected,
                  onDismiss: _popup.hide,
                ),
                child: Container(
                  width: width,
                  height: _expandedHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: const [
                      BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Color(0x33000000)),
                      BoxShadow(blurRadius: 16, offset: Offset(0, 4), color: Color(0x1A000000)),
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
                                    icon: ToolbarIcon.wand,
                                    color: const Color(0xFFFFFFFF),
                                    strokeWidth: 1.8,
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
                            child: StoreBuilder<SelectionStore, SelectionState>(
                              builder: (context, selection) => _ControlsRow(
                                highlightsVisible: widget.highlightsVisible,
                                hasSelection: selection.hasSelection,
                                onToggleHighlights: widget.onToggleHighlights,
                                onCopy: widget.onCopySelection,
                                onClear: widget.onClearSelection,
                                onSettings: _toggleSettings,
                                onClose: _collapse,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
  final bool highlightsVisible;
  final bool hasSelection;
  final VoidCallback onToggleHighlights;
  final VoidCallback onCopy;
  final VoidCallback onClear;
  final VoidCallback onSettings;
  final VoidCallback onClose;

  const _ControlsRow({
    required this.highlightsVisible,
    required this.hasSelection,
    required this.onToggleHighlights,
    required this.onCopy,
    required this.onClear,
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
            onTap: hasSelection ? onCopy : null,
          ),
          ToolbarControlButton(
            icon: ToolbarIcon.trash,
            onTap: hasSelection ? onClear : null,
          ),
          ToolbarControlButton(
            icon: ToolbarIcon.eye,
            active: !highlightsVisible,
            onTap: onToggleHighlights,
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
