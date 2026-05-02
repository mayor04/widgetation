/// On-demand widget tree streamer for Flutter.
///
/// Wrap your app's root with [InspectorStreamer] and the package will host a
/// local WebSocket server. When the desktop viewer connects and signals
/// focus, the streamer begins capturing the widget tree (PNG + per-widget
/// metadata) and pushing frames at a modest rate. When the viewer
/// disconnects or loses focus, capture stops — overhead stays near zero
/// during normal development.
library;

export 'src/config.dart' show WidgetationConfig;
export 'src/inspector_streamer.dart' show InspectorStreamer;
