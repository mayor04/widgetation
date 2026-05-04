# widgetation

On-device widget inspector for Flutter. Wrap your app once and a floating
button mounts over your UI; tapping it lets you pick widgets, attach
feedback, and copy the collected notes to the clipboard.

## Why

Flutter DevTools is a heavy attach-and-introspect tool. This package is a
much smaller, in-app surface: tap or marquee-drag to select widgets,
write notes anchored to specific widgets, and ship the result as a
formatted feedback list — handy for design reviews and bug filing.

## Install

```yaml
dependencies:
  widgetation: ^0.1.0
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  runApp(const Widgetation(child: MyApp()));
}
```

That's the whole integration surface. In release mode the wrapper is a
no-op.

## License

MIT.
