import 'package:flutter/widgets.dart';

/// What [Widgetation] does at runtime.
enum WidgetationMode {
  /// No-op. Same effect as `enabled: false`.
  none,

  /// Render a floating button; tapping it enters an on-device select
  /// overlay that highlights the widget under the pointer and lets the
  /// user attach feedback to specific widgets.
  edit,
}

/// Configuration for [Widgetation].
class WidgetationConfig {
  final WidgetationMode mode;

  /// Where the floating select-mode button sits in [WidgetationMode.edit].
  final AlignmentGeometry selectButtonAlignment;

  /// Kill switch. When false, [Widgetation] no-ops regardless of [mode].
  final bool enabled;

  const WidgetationConfig({
    this.mode = WidgetationMode.edit,
    this.selectButtonAlignment = Alignment.bottomRight,
    this.enabled = true,
  });

  bool get isActive => enabled && mode != WidgetationMode.none;
}
