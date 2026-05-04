import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'edits_clipboard.dart';
import 'select_mode_layer.dart';
import 'settings_gate.dart';
import 'state/edits_store.dart';
import 'state/hover_store.dart';
import 'state/preferences_store.dart';
import 'state/selection_store.dart';
import 'state/ui_state_store.dart';
import 'state/widgetation_store.dart';
import 'themed_host.dart';
import 'toolbar/toolbar.dart';
import 'widget_picker.dart';

/// Wrap your app's root with [Widgetation] to mount an on-device inspector
/// overlay. Tap the floating button to enter select mode, pick widgets,
/// and attach feedback notes.
///
/// ```dart
/// void main() {
///   runApp(const Widgetation(child: MyApp()));
/// }
/// ```
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
  final GlobalKey _rootKey = GlobalKey(debugLabel: 'widgetation.root');

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
    if (cfg.mode == WidgetationMode.edit) {
      _picker = WidgetPicker();
      _selection = SelectionStore();
      _hover = HoverStore();
      _edits = EditsStore();
      _prefs = PreferencesStore()..load();
    }
  }

  @override
  void dispose() {
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

    final wrapped = RepaintBoundary(key: _rootKey, child: widget.child);
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
                    // by _rootKey.
                    wrapped,
                    // Gesture overlay + visual highlights + edits + chat
                    // box. Mounts only when select mode is active. Owns
                    // its own theme subscription. Uses a translucent
                    // gesture surface so trackpad pan-zoom and mouse
                    // wheel reach the user's scrollables; inspector
                    // tap/drag recognizers still win the gesture arena.
                    SelectModeLayer(
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
                    ThemedHost(
                      child: RepaintBoundary(
                        child: WidgetationToolbar(
                          alignment: cfg.selectButtonAlignment,
                          onCopyEdits: _copyAllEdits,
                          onDeleteEdits: _deleteAllEdits,
                          onToggleEditsHidden: _toggleEditsHidden,
                          onToggleSettings: _toggleSettings,
                          onExpandedChanged: _setSelectActive,
                        ),
                      ),
                    ),
                    // Settings popup — mounts only when settingsOpen.
                    SettingsGate(
                      open: _ui.settingsOpen,
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
    Clipboard.setData(ClipboardData(text: formatEditsForClipboard(edits)));
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
    final ctx = _rootKey.currentContext;
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
