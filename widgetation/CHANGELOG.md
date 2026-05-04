## 0.2.1

* Lower SDK floor to Dart 3.0 / Flutter 3.10 so the package works on older
  Flutter versions.

## 0.2.0

Replaces the WebSocket-viewer architecture with an on-device overlay. Wrap
your app with `Widgetation` and the inspector mounts directly over your UI —
no companion app required.

### Breaking changes

* Removed `InspectorStreamer` and the WebSocket streaming server. Use
  `Widgetation` at your app root instead.
* New public API: `Widgetation`, `WidgetationConfig`, `WidgetationMode`.

### New

* Floating toolbar with pause, highlight, copy, and clear controls.
* Select mode: tap to pick a widget, marquee-drag to select multiple
  widgets into a single edit, with ancestor-chain disambiguation for
  nested picks.
* Picks widgets through dialogs and popovers.
* Forwards wheel and trackpad scrolls to the user app while in select mode.
* Inline chat box for attaching notes per selection, with structured copy
  to clipboard for pasting into Claude Code, Codex, or other AI tools.
* Settings popup for theme and marker color, persisted via
  `shared_preferences`.

## 0.1.0

* Initial release. `InspectorStreamer` widget + WebSocket server with
  on-demand capture gated by viewer focus.
