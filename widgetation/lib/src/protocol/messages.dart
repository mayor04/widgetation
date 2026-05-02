/// Typed messages on the WebSocket protocol.
///
/// `ViewerMessage` is anything coming from the desktop viewer; `ServerMessage`
/// is anything we emit. `ServerMessage` is non-sealed because [Frame] lives
/// in its own file (Dart sealed classes require all variants in one library).
sealed class ViewerMessage {
  static ViewerMessage? parse(Map<String, Object?> json) {
    return switch (json['type']) {
      'focus' => FocusMessage(focused: json['focused'] == true),
      'hello' => HelloMessage(
          fps: json['fps'] is int ? json['fps'] as int : null,
        ),
      _ => null,
    };
  }
}

class FocusMessage extends ViewerMessage {
  final bool focused;
  FocusMessage({required this.focused});
}

class HelloMessage extends ViewerMessage {
  final int? fps;
  HelloMessage({this.fps});
}

abstract class ServerMessage {
  Map<String, Object?> toJson();
}

class ServerHello extends ServerMessage {
  final String name;
  final int version;
  ServerHello({required this.name, this.version = 1});

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'hello',
        'name': name,
        'version': version,
      };
}
