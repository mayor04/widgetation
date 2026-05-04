# widgetation

**Visual feedback. For agents.**

Widgetation turns UI annotations into structured context that AI coding agents can understand and act on. Click any element, add a note, and paste the output into Claude Code, Codex, or any AI tool.

Inspired by [agentation](https://github.com/agentation).

## How you use it

1. Click the **◎** icon in the bottom-right corner to activate
2. Hover over elements to see their names highlighted
3. Click any element to add an annotation
4. Write your feedback and click **Add**
5. Click **⧉** to copy formatted markdown
6. Paste into your agent

## Setup

### Prompt setup (recommended)

Copy this prompt into your agent and let it wire everything up:

```text
Add the widgetation package to this Flutter app.

1. Add `widgetation: ^0.1.0` to pubspec.yaml under dependencies.
2. Run `flutter pub get`.
3. In lib/main.dart, import `package:widgetation/widgetation.dart`
   and wrap the root widget passed to runApp with `Widgetation(child: ...)`.
   Example: `runApp(const Widgetation(child: MyApp()));`
4. Do not change anything else.
```

### Manual setup

Add the dependency:

```yaml
dependencies:
  widgetation: ^0.1.0
```

Wrap your app's root:

```dart
import 'package:flutter/material.dart';
import 'package:widgetation/widgetation.dart';

void main() {
  runApp(const Widgetation(child: MyApp()));
}
```

That's it. The overlay only mounts in debug and profile builds — in release mode `Widgetation` is a no-op, so it's safe to leave wrapped.

## What you get

- **Click to annotate** — pick any widget, attach a note
- **Marquee select** — drag across multiple widgets to annotate them as a group
- **Formatted output** — copy as markdown with widget names, locations, and your notes
- **Zero release-mode cost** — wrapper compiles out

## Compatibility

- Flutter `>=3.10.0`
- Dart SDK `^3.11.1`
- iOS, Android, macOS, Windows, Linux, web

## License

MIT.
