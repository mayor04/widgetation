import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'edits/edits_layer.dart';
import 'frame_capturer.dart';
import 'select_mode_overlay.dart';
import 'state/edits_store.dart';
import 'state/hover_store.dart';
import 'state/selection_store.dart';
import 'state/widgetation_store.dart';
import 'streaming_server.dart';
import 'toolbar/toolbar.dart';
import 'tree_builder.dart';
import 'widget_picker.dart';

/// Wrap your app's root with [Widgetation] to expose a local WebSocket
/// server that streams screenshots + widget tree metadata on demand.
///
/// ```dart
/// void main() {
///   runApp(const Widgetation(child: MyApp()));
/// }
/// ```
///
/// Capture is gated: it only runs while a viewer is connected and reports
/// itself focused. There is no continuous overhead during normal use.
class Widgetation extends StatefulWidget {
  /// Your application's root widget.
  final Widget child;

  /// Optional configuration. See [WidgetationConfig].
  final WidgetationConfig config;

  const Widgetation({super.key, required this.child, this.config = const WidgetationConfig()});

  @override
  State<Widgetation> createState() => _WidgetationState();
}

class _WidgetationState extends State<Widgetation> {
  final GlobalKey _captureKey = GlobalKey(debugLabel: 'widgetation.capture');
  StreamingServer? _server;
  FrameCapturer? _capturer;
  Timer? _timer;
  bool _busy = false;

  WidgetPicker? _picker;
  bool _selectActive = false;
  bool _paused = false;
  bool _highlightsVisible = true;
  ScrollPosition? _panTarget;

  SelectionStore? _selection;
  HoverStore? _hover;
  EditsStore? _edits;

  @override
  void initState() {
    super.initState();
    final cfg = widget.config;
    if (!cfg.isActive || kReleaseMode) return;
    if (cfg.mode == WidgetationMode.image) {
      _boot();
    } else if (cfg.mode == WidgetationMode.edit) {
      _picker = WidgetPicker();
      _selection = SelectionStore();
      _hover = HoverStore();
      _edits = EditsStore();
    }
  }

  Future<void> _boot() async {
    final cfg = widget.config;
    final server = StreamingServer(host: cfg.host, port: cfg.port, name: cfg.name);
    try {
      await server.start();
    } catch (e) {
      debugPrint('[widgetation] failed to bind ${cfg.host}:${cfg.port}: $e');
      return;
    }
    server.shouldCapture.addListener(_onShouldCaptureChanged);
    _server = server;
    _capturer = FrameCapturer(
      boundaryKey: _captureKey,
      treeBuilder: TreeBuilder(),
      pixelRatioOverride: cfg.pixelRatio,
    );
    if (server.shouldCapture.value) _onShouldCaptureChanged();
  }

  void _onShouldCaptureChanged() {
    final should = _server?.shouldCapture.value ?? false;
    if (should) {
      _start();
    } else {
      _stop();
    }
  }

  void _start() {
    _timer?.cancel();
    final fps = (_server?.requestedFps.value ?? widget.config.clampedFps).clamp(1, 30);
    final period = Duration(milliseconds: (1000 / fps).round());
    _timer = Timer.periodic(period, (_) => _tick());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    if (_busy || _paused) return;
    if (_server?.hasViewer != true) return;
    _busy = true;
    try {
      final frame = await _capturer?.captureOnce();
      if (frame != null) _server?.send(frame);
    } catch (e, st) {
      debugPrint('[widgetation] capture failed: $e\n$st');
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _server?.shouldCapture.removeListener(_onShouldCaptureChanged);
    _server?.stop();
    _selection?.dispose();
    _hover?.dispose();
    _edits?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    if (!cfg.isActive || kReleaseMode) return widget.child;

    final wrapped = RepaintBoundary(key: _captureKey, child: widget.child);
    if (cfg.mode != WidgetationMode.edit) return wrapped;

    // Widgetation sits above MaterialApp, so there is no Directionality or
    // MediaQuery in scope yet — provide both ourselves so the overlay
    // (Stack default-aligns AlignmentDirectional, SafeArea reads padding)
    // works regardless of how the user wires their app.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery.fromView(
        view: View.of(context),
        child: StoreScope<SelectionStore>(
          store: _selection!,
          child: StoreScope<HoverStore>(
            store: _hover!,
            child: StoreScope<EditsStore>(
              store: _edits!,
              child: Stack(
              children: [
                // User app. While select mode is active it stops receiving
                // any pointer events at all — taps don't fire. We forward
                // pans manually below so scrolling still works.
                IgnorePointer(ignoring: _selectActive, child: wrapped),
                if (_selectActive)
                  Positioned.fill(
                    child: MouseRegion(
                      onHover: (e) => _onHover(e.position),
                      onExit: (_) => _onHover(null),
                      cursor: SystemMouseCursors.precise,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) => _onHover(d.globalPosition),
                        onTapUp: (d) => _onTapAt(d.globalPosition),
                        onTapCancel: () => _onHover(null),
                        onPanDown: _onPanDown,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        onPanCancel: _onPanCancel,
                      ),
                    ),
                  ),
                if (_selectActive && _highlightsVisible)
                  const SelectionHighlights(),
                if (_selectActive && _highlightsVisible)
                  const SelectionInfoChip(),
                if (_selectActive) const EditsLayer(),
                WidgetationToolbar(
                  alignment: cfg.selectButtonAlignment,
                  config: cfg,
                  selectActive: _selectActive,
                  paused: _paused,
                  highlightsVisible: _highlightsVisible,
                  serverRunning: _server != null,
                  viewerConnected: _server?.hasViewer ?? false,
                  onToggleSelect: _toggleSelect,
                  onTogglePause: _togglePause,
                  onToggleHighlights: _toggleHighlights,
                  onCopySelection: _copySelection,
                  onClearSelection: _clearSelection,
                  onExpandedChanged: _setSelectActive,
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSelect() {
    setState(() => _selectActive = !_selectActive);
    if (!_selectActive) {
      _selection?.clear();
      _hover?.clear();
      _edits?.cancelDraft();
    }
  }

  void _setSelectActive(bool active) {
    if (_selectActive == active) return;
    setState(() => _selectActive = active);
    if (!active) {
      _selection?.clear();
      _hover?.clear();
      _edits?.cancelDraft();
    }
  }

  void _togglePause() => setState(() => _paused = !_paused);

  void _toggleHighlights() => setState(() => _highlightsVisible = !_highlightsVisible);

  void _copySelection() {
    final s = _selection?.value.primary;
    if (s == null) return;
    final loc = s.file == null ? s.type : '${s.type} · ${s.file}:${s.line ?? '?'}';
    Clipboard.setData(ClipboardData(text: loc));
  }

  void _clearSelection() {
    if (_edits?.value.hasOpenDraft ?? false) {
      _edits?.shake();
      return;
    }
    _selection?.clear();
    _hover?.clear();
  }

  Element? _root() {
    final ctx = _captureKey.currentContext;
    return ctx is Element ? ctx : null;
  }

  void _onHover(Offset? pos) {
    final picker = _picker;
    final root = _root();
    if (picker == null || root == null) return;
    final hit = pos == null ? null : picker.findAt(root, pos);
    _hover?.set(hit, pos);
  }

  void _onTapAt(Offset pos) {
    final picker = _picker;
    final root = _root();
    if (picker == null || root == null) return;
    // While a chat box is open the user can still hover, but tapping a
    // different widget just nudges the chat box — selection is locked
    // until they Cancel or Add.
    if (_edits?.value.hasOpenDraft ?? false) {
      _edits?.shake();
      return;
    }
    final hit = picker.findAt(root, pos);
    _selection?.select(hit);
    if (hit != null) {
      _edits?.beginCompose(cursor: pos, node: hit);
      debugPrint('#--> type=${hit.type}');
      debugPrint('     nearest=${hit.nearestWidget}');
      debugPrint('     ancestors=${hit.ancestors.join(' › ')}');
      debugPrint('     file=${hit.file}:${hit.line}');
      debugPrint('     props=${hit.widgetProperties}');
    }
  }

  void _onPanDown(DragDownDetails d) {
    final picker = _picker;
    final root = _root();
    if (picker == null || root == null) return;
    final el = picker.elementAt(root, d.globalPosition);
    _panTarget = el == null ? null : Scrollable.maybeOf(el)?.position;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final pos = _panTarget;
    if (pos == null) return;
    final delta = pos.axis == Axis.vertical ? d.delta.dy : d.delta.dx;
    final next = (pos.pixels - delta).clamp(pos.minScrollExtent, pos.maxScrollExtent);
    pos.jumpTo(next);
  }

  void _onPanEnd(DragEndDetails d) => _panTarget = null;
  void _onPanCancel() => _panTarget = null;
}
