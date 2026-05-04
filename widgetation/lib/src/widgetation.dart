import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'edits/edit_label.dart';
import 'edits/edits_layer.dart';
import 'frame_capturer.dart';
import 'marquee_overlay.dart';
import 'select_mode_overlay.dart';
import 'state/edits_store.dart';
import 'state/hover_store.dart';
import 'state/preferences_store.dart';
import 'state/selection_store.dart';
import 'state/ui_state_store.dart';
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

  // Plain non-state fields used by the marquee handlers; the live rect
  // flows through _ui.marquee instead of triggering setState.
  Offset? _marqueeStart;
  Offset? _marqueeCurrent;

  SelectionStore? _selection;
  HoverStore? _hover;
  EditsStore? _edits;
  PreferencesStore? _prefs;
  final UiStateStore _ui = UiStateStore();

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
    _ui.dispose();
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
    //
    // The build runs once on mount: every interactive piece of state lives
    // in a ValueNotifier (UiStateStore) or a WidgetationStore further down
    // and is consumed by a leaf widget that subscribes only to itself.
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
                child: Stack(
                  children: [
                    // User app — stable sibling, never re-rendered by
                    // inspector state. Already a RepaintBoundary anchored
                    // by _captureKey.
                    wrapped,
                    // Swallows pointer events while select mode is on so
                    // taps and pans go to the inspector overlay instead
                    // of the user's scrollables. Sits above the user app
                    // and below the gesture overlay in the Stack.
                    _SelectModeAbsorber(active: _ui.selectActive),
                    // Gesture overlay + visual highlights + edits + chat
                    // box. Mounts only when select mode is active. Owns
                    // its own theme subscription.
                    _SelectModeOverlays(
                      ui: _ui,
                      onHover: _onHover,
                      onTapAt: _onTapAt,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      onPanCancel: _onPanCancel,
                    ),
                    // Toolbar — always mounted; subscribes to theme on
                    // its own, and to EditsStore inside its expanded row.
                    _ThemedHost(
                      child: RepaintBoundary(
                        child: WidgetationToolbar(
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
                      ),
                    ),
                    // Settings popup — mounts only when settingsOpen.
                    _SettingsGate(
                      open: _ui.settingsOpen,
                      config: cfg,
                      serverRunning: _server != null,
                      viewerConnected: _server?.hasViewer ?? false,
                      onDismiss: _closeSettings,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setSelectActive(bool active) {
    if (_ui.selectActive.value == active) return;
    _ui.selectActive.value = active;
    if (!active) {
      _ui.settingsOpen.value = false;
      _selection?.clear();
      _hover?.clear();
      _edits?.cancelDraft();
    }
  }

  void _toggleSettings() => _ui.settingsOpen.value = !_ui.settingsOpen.value;

  void _closeSettings() {
    if (!_ui.settingsOpen.value) return;
    _ui.settingsOpen.value = false;
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
    // Add. An empty draft is fair game to discard and re-anchor. The
    // chat box owns the in-flight text via its own controller; it
    // publishes a hasDraftText signal we read here.
    final draft = _edits?.value.draft;
    if (draft != null) {
      if (_edits?.hasDraftText.value ?? false) {
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

  void _onPanStart(DragStartDetails d) {
    // Mid-draft pan with typed text should nudge; an empty draft is
    // discarded so the marquee can begin.
    final draft = _edits?.value.draft;
    if (draft != null) {
      if (_edits?.hasDraftText.value ?? false) {
        _edits?.shake();
        return;
      }
      _edits?.cancelDraft();
    }
    _marqueeStart = d.globalPosition;
    _marqueeCurrent = d.globalPosition;
    _ui.marquee.value = Rect.fromPoints(d.globalPosition, d.globalPosition);
    _hover?.clear();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    final start = _marqueeStart;
    if (start == null) return;
    _marqueeCurrent = d.globalPosition;
    _ui.marquee.value = Rect.fromPoints(start, d.globalPosition);
  }

  void _onPanEnd(DragEndDetails d) {
    final start = _marqueeStart;
    final end = _marqueeCurrent;
    _marqueeStart = null;
    _marqueeCurrent = null;
    _ui.marquee.value = null;
    if (start == null || end == null) return;
    _finishMarquee(Rect.fromPoints(start, end), end);
  }

  void _onPanCancel() {
    if (_marqueeStart == null) return;
    _marqueeStart = null;
    _marqueeCurrent = null;
    _ui.marquee.value = null;
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

/// Rebuilds only when `selectActive` flips. Mounts a full-screen
/// `AbsorbPointer` so taps and pans don't reach the user's app while
/// the inspector owns input.
class _SelectModeAbsorber extends StatelessWidget {
  final ValueListenable<bool> active;

  const _SelectModeAbsorber({required this.active});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: active,
      builder: (context, on, _) {
        if (!on) return const SizedBox.shrink();
        return const Positioned.fill(
          child: RepaintBoundary(
            child: AbsorbPointer(child: SizedBox.expand()),
          ),
        );
      },
    );
  }
}

/// Inspector visuals: gesture overlay, marquee paint, selection highlights,
/// info chip, edits layer. Mounts only while `selectActive` is true and
/// hosts its own [WidgetationTheme] consumer so theme changes don't
/// invalidate widgets above.
class _SelectModeOverlays extends StatelessWidget {
  final UiStateStore ui;
  final void Function(Offset?) onHover;
  final void Function(Offset) onTapAt;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final GestureDragCancelCallback onPanCancel;

  const _SelectModeOverlays({
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
        return _ThemedHost(
          child: RepaintBoundary(
            child: Stack(
              children: [
                Positioned.fill(
                  child: MouseRegion(
                    onHover: (e) => onHover(e.position),
                    onExit: (_) => onHover(null),
                    cursor: SystemMouseCursors.precise,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => onHover(d.globalPosition),
                      onTapUp: (d) => onTapAt(d.globalPosition),
                      onTapCancel: () => onHover(null),
                      onPanStart: onPanStart,
                      onPanUpdate: onPanUpdate,
                      onPanEnd: onPanEnd,
                      onPanCancel: onPanCancel,
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

/// Mounts the settings popup only while `open` is true. Hosts its own
/// theme consumer so opening/closing it doesn't ripple to the toolbar
/// or the select-mode overlay.
class _SettingsGate extends StatelessWidget {
  final ValueListenable<bool> open;
  final WidgetationConfig config;
  final bool serverRunning;
  final bool viewerConnected;
  final VoidCallback onDismiss;

  const _SettingsGate({
    required this.open,
    required this.config,
    required this.serverRunning,
    required this.viewerConnected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: open,
      builder: (context, isOpen, _) {
        if (!isOpen) return const SizedBox.shrink();
        return _ThemedHost(
          child: RepaintBoundary(
            child: ToolbarStatusPopup(
              config: config,
              serverRunning: serverRunning,
              viewerConnected: viewerConnected,
              onDismiss: onDismiss,
            ),
          ),
        );
      },
    );
  }
}

/// Subscribes to [PreferencesStore] and republishes the resulting
/// [WidgetationThemeData] via [WidgetationTheme]. Scoped per consumer
/// so theme changes don't bubble through the entire widget tree — only
/// the subtree below this host rebuilds.
class _ThemedHost extends StatelessWidget {
  final Widget child;

  const _ThemedHost({required this.child});

  @override
  Widget build(BuildContext context) {
    return StoreBuilder<PreferencesStore, PreferencesState>(
      builder: (context, prefs) {
        final base = prefs.themeMode == WidgetationThemeMode.light
            ? kWidgetationLightTheme
            : kWidgetationDarkTheme;
        final theme = base.withAccent(prefs.markerColor);
        return WidgetationTheme(data: theme, child: child);
      },
    );
  }
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
