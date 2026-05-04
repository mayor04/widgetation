import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'edits/edit_label.dart';
import 'edits/edits_layer.dart';
import 'frame_capturer.dart';
import 'select_mode_overlay.dart';
import 'state/edits_store.dart';
import 'state/hover_store.dart';
import 'state/preferences_store.dart';
import 'state/selection_store.dart';
import 'state/widgetation_store.dart';
import 'streaming_server.dart';
import 'theme.dart';
import 'toolbar/status_popup.dart';
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
  bool _settingsOpen = false;
  Offset? _marqueeStart;
  Offset? _marqueeCurrent;

  SelectionStore? _selection;
  HoverStore? _hover;
  EditsStore? _edits;
  PreferencesStore? _prefs;

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
      _prefs = PreferencesStore()..load();
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
    if (_busy) return;
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
    _prefs?.dispose();
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
        child: StoreScope<PreferencesStore>(
          store: _prefs!,
          child: StoreScope<SelectionStore>(
            store: _selection!,
            child: StoreScope<HoverStore>(
              store: _hover!,
              child: StoreScope<EditsStore>(
                store: _edits!,
                child: StoreBuilder<PreferencesStore, PreferencesState>(
                  builder: (context, prefs) {
                    final base = prefs.themeMode == WidgetationThemeMode.light
                        ? kWidgetationLightTheme
                        : kWidgetationDarkTheme;
                    final theme = base.withAccent(prefs.markerColor);
                    return WidgetationTheme(
                      data: theme,
                      child: Stack(
                        children: [
                          // User app. While select mode is active it stops
                          // receiving any pointer events — taps and pans
                          // are claimed by our overlay so the inspector
                          // can pick widgets and draw a marquee instead
                          // of forwarding to the underlying scrollables.
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
                                  onPanStart: _onPanStart,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  onPanCancel: _onPanCancel,
                                ),
                              ),
                            ),
                          if (_selectActive && _marqueeRect != null)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _MarqueePainter(_marqueeRect!),
                                ),
                              ),
                            ),
                          if (_selectActive) const SelectionHighlights(),
                          if (_selectActive) const SelectionInfoChip(),
                          if (_selectActive) const EditsLayer(),
                          WidgetationToolbar(
                            alignment: cfg.selectButtonAlignment,
                            config: cfg,
                            serverRunning: _server != null,
                            viewerConnected: _server?.hasViewer ?? false,
                            onCopyEdits: _copyAllEdits,
                            onDeleteEdits: _deleteAllEdits,
                            onToggleEditsHidden: _toggleEditsHidden,
                            onToggleSettings: _toggleSettings,
                            onExpandedChanged: _setSelectActive,
                          ),
                          if (_settingsOpen)
                            ToolbarStatusPopup(
                              config: cfg,
                              serverRunning: _server != null,
                              viewerConnected: _server?.hasViewer ?? false,
                              onDismiss: _closeSettings,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setSelectActive(bool active) {
    if (_selectActive == active) return;
    setState(() {
      _selectActive = active;
      if (!active) _settingsOpen = false;
    });
    if (!active) {
      _selection?.clear();
      _hover?.clear();
      _edits?.cancelDraft();
    }
  }

  void _toggleSettings() => setState(() => _settingsOpen = !_settingsOpen);

  void _closeSettings() {
    if (!_settingsOpen) return;
    setState(() => _settingsOpen = false);
  }

  void _copyAllEdits() {
    final edits = _edits?.value.edits ?? const [];
    if (edits.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _formatEditsForClipboard(edits)));
    if (_prefs?.value.clearOnCopy ?? false) {
      // Don't destroy work if a draft is mid-compose; nudge the chat box
      // so the user notices instead.
      if (_edits?.value.hasOpenDraft ?? false) {
        _edits?.shake();
      } else {
        _edits?.clear();
        _selection?.clear();
        _hover?.clear();
      }
    }
  }

  void _deleteAllEdits() => _edits?.clear();

  void _toggleEditsHidden() => _edits?.toggleHidden();

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
    // While a chat box with typed text is open, tapping a different
    // widget just nudges it — selection is locked until they Cancel or
    // Add. An empty draft is fair game to discard and re-anchor.
    final draft = _edits?.value.draft;
    if (draft != null) {
      if (draft.text.trim().isNotEmpty) {
        _edits?.shake();
        return;
      }
      _edits?.cancelDraft();
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

  Rect? get _marqueeRect {
    final a = _marqueeStart;
    final b = _marqueeCurrent;
    if (a == null || b == null) return null;
    return Rect.fromPoints(a, b);
  }

  void _onPanStart(DragStartDetails d) {
    // Mid-draft pan with typed text should nudge; an empty draft is
    // discarded so the marquee can begin.
    final draft = _edits?.value.draft;
    if (draft != null) {
      if (draft.text.trim().isNotEmpty) {
        _edits?.shake();
        return;
      }
      _edits?.cancelDraft();
    }
    setState(() {
      _marqueeStart = d.globalPosition;
      _marqueeCurrent = d.globalPosition;
    });
    _hover?.clear();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_marqueeStart == null) return;
    setState(() => _marqueeCurrent = d.globalPosition);
  }

  void _onPanEnd(DragEndDetails d) {
    final start = _marqueeStart;
    final end = _marqueeCurrent;
    setState(() {
      _marqueeStart = null;
      _marqueeCurrent = null;
    });
    if (start == null || end == null) return;
    _finishMarquee(Rect.fromPoints(start, end), end);
  }

  void _onPanCancel() {
    if (_marqueeStart == null) return;
    setState(() {
      _marqueeStart = null;
      _marqueeCurrent = null;
    });
  }

  void _finishMarquee(Rect marquee, Offset end) {
    final picker = _picker;
    final root = _root();
    if (picker == null || root == null) return;
    // Treat sub-slop drags as a no-op; the GestureDetector's tap path
    // should have fired instead.
    if (marquee.width < 4 && marquee.height < 4) return;

    final hits = picker.findAllIn(root, marquee);
    if (hits.isEmpty) return;

    Rect? union;
    for (final n in hits) {
      final r = Rect.fromLTWH(n.rect.x, n.rect.y, n.rect.w, n.rect.h);
      union = union == null ? r : union.expandToInclude(r);
    }
    if (union == null) return;

    _selection?.selectMany(hits);
    _edits?.beginComposeMulti(cursor: end, nodes: hits, selectRect: union);
  }
}

class _MarqueePainter extends CustomPainter {
  static const Color _green = Color(0xFF00C853);
  static const Color _greenFill = Color(0x3300C853);

  final Rect rect;
  _MarqueePainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(rect, Paint()..color = _greenFill);
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _green,
    );
  }

  @override
  bool shouldRepaint(covariant _MarqueePainter old) => old.rect != rect;
}

String _formatEditsForClipboard(List<Edit> edits) {
  final sb = StringBuffer('### **Page Feedback List**\n\n');
  for (final edit in edits) {
    final label = edit.nodes.isEmpty
        ? '(unknown)'
        : formatMultiNodeLabel(edit.nodes);
    final source = _formatEditSources(edit);
    sb.writeln('${edit.index}. $label');
    sb.writeln('Source: $source');
    sb.writeln('Feedback: ${edit.text}');
    sb.writeln();
  }
  return sb.toString().trimRight();
}

String _formatEditSources(Edit edit) {
  if (edit.nodes.isEmpty) return '(unknown)';
  final parts = <String>{};
  for (var i = 0; i < edit.nodes.length; i++) {
    final node = edit.nodes[i];
    final file = i < edit.files.length ? edit.files[i] : node.file;
    if (file == null) continue;
    parts.add('$file:${node.line ?? '?'}');
  }
  if (parts.isEmpty) return '(unknown)';
  return parts.join(', ');
}
