/// On-demand widget tree streamer for Flutter.
///
/// Wrap your app's root with `InspectorStreamer` (forthcoming) and the
/// package will host a local WebSocket server that streams the widget
/// tree to a desktop viewer.
library;

export 'src/config.dart' show WidgetationConfig;
export 'src/inspector_streamer.dart' show InspectorStreamer;
