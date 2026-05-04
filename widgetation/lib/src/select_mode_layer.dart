import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'edits/edits_layer.dart';
import 'marquee_overlay.dart';
import 'select_mode_overlay.dart';
import 'state/ui_state_store.dart';
import 'themed_host.dart';

/// Inspector visuals: gesture overlay, marquee paint, selection highlights,
/// info chip, edits layer. Mounts only while `selectActive` is true and
/// hosts its own [WidgetationTheme] consumer so theme changes don't
/// invalidate widgets above.
class SelectModeLayer extends StatelessWidget {
  final UiStateStore ui;
  final void Function(Offset?) onHover;
  final void Function(Offset) onTapAt;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final GestureDragCancelCallback onPanCancel;

  const SelectModeLayer({
    super.key,
    required this.ui,
    required this.onHover,
    required this.onTapAt,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onPanCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ui.selectActive,
      builder: (context, on, _) {
        if (!on) return const SizedBox.shrink();
        return ThemedHost(
          child: RepaintBoundary(
            child: Stack(
              children: [
                Positioned.fill(
                  child: MouseRegion(
                    onHover: (e) => onHover(e.position),
                    onExit: (_) => onHover(null),
                    cursor: SystemMouseCursors.precise,
                    child: RawGestureDetector(
                      // Translucent so trackpad pan-zoom and pointer signals
                      // (mouse wheel) reach scrollables in the user's app
                      // below. Inspector tap/drag recognizers still win the
                      // gesture arena because they sit topmost.
                      behavior: HitTestBehavior.translucent,
                      gestures: <Type, GestureRecognizerFactory>{
                        TapGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                          () => TapGestureRecognizer(),
                          (instance) {
                            instance.onTapDown = (d) {
                              onHover(d.globalPosition);
                            };
                            instance.onTapUp = (d) {
                              onTapAt(d.globalPosition);
                            };
                            instance.onTapCancel = () {
                              onHover(null);
                            };
                          },
                        ),
                        // Restrict marquee pan to physical drag devices.
                        // Two-finger trackpad scroll arrives as pan-zoom
                        // events and would otherwise start a marquee — let
                        // those fall through to the underlying scrollable.
                        PanGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                          () => PanGestureRecognizer(
                            supportedDevices: const {
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.touch,
                              PointerDeviceKind.stylus,
                              PointerDeviceKind.invertedStylus,
                              PointerDeviceKind.unknown,
                            },
                          ),
                          (instance) {
                            instance
                              ..onStart = onPanStart
                              ..onUpdate = onPanUpdate
                              ..onEnd = onPanEnd
                              ..onCancel = onPanCancel;
                          },
                        ),
                      },
                    ),
                  ),
                ),
                MarqueeOverlay(rect: ui.marquee),
                // Each of these returns a Positioned.fill / Positioned
                // internally, so they must be DIRECT children of the Stack
                // (Positioned applies parent data to its render-tree child
                // and requires the render parent to be a RenderStack — a
                // wrapping RepaintBoundary would break that). Each widget
                // wraps its own contents in a RepaintBoundary internally.
                const SelectionHighlights(),
                const SelectionInfoChip(),
                const EditsLayer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
