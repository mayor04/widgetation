/// On-device widget inspector for Flutter.
///
/// Wrap your app's root with [Widgetation] and a floating button mounts
/// over your UI. Tapping it enters select mode: tap a widget to highlight
/// it, drag to marquee-select multiple widgets, attach feedback, and copy
/// the collected notes to the clipboard.
library;

export 'src/config.dart' show WidgetationConfig, WidgetationMode;
export 'src/widgetation.dart' show Widgetation;
