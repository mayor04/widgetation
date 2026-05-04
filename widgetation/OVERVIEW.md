# widgetation — Package Overview

`widgetation` is a small Flutter package that mounts an on-device widget
inspector into any app. You wrap your app's root once; a floating button
appears over your UI, and tapping it enters select mode where you can
pick widgets, attach feedback notes, and copy the collected list to the
clipboard.

## Goals

- **Single-line integration.** `runApp(Widgetation(child: MyApp()))` is
  the entire setup. No platform plugins, no native code.
- **Zero overhead at rest.** The inspector overlay only intercepts input
  while select mode is on. In release builds the wrapper is a no-op and
  returns `child` unchanged.
- **Ship the feedback.** Selections, marquee groups, and per-widget notes
  are formatted into a markdown feedback list ready to paste into a
  ticket or share with the team.

## Files

```
widgetation/
├── lib/
│   ├── widgetation.dart            # public exports: Widgetation, WidgetationConfig
│   └── src/
│       ├── config.dart             # WidgetationConfig: mode, alignment, enabled
│       ├── widgetation.dart        # the StatefulWidget wrapper + overlay wiring
│       ├── widget_picker.dart      # element-tree hit testing
│       ├── tree_builder.dart       # element-tree → TreeNode walker
│       ├── tree_node.dart          # picked-node data model
│       ├── select_mode_overlay.dart, marquee_overlay.dart, edits/, toolbar/, state/
└── pubspec.yaml                    # name: widgetation, version: 0.1.0
```

## How it fits together

`Widgetation` is the only public widget. Behind the scenes:

1. **Mount.** In debug/profile mode (and only when `config.enabled`),
   the widget builds a `RepaintBoundary` around `child` and mounts the
   floating toolbar plus an absorber/overlay layer above it. In release
   mode `build` returns `child` unchanged.
2. **Idle.** Until the user taps the toolbar to enter select mode, the
   absorber is inert and the user app receives all input as normal.
3. **Select mode.** Tapping the toolbar opens it and toggles
   `selectActive`. A full-screen `AbsorbPointer` swallows input from the
   user app while a gesture overlay above it routes taps and drags to
   the picker. Tapping picks a widget; dragging marquee-selects a group.
4. **Feedback.** Each selection opens a chat box anchored at the cursor;
   typed notes are stored in `EditsStore` and rendered as marker labels
   above the picked widgets.
5. **Copy.** The toolbar's copy button writes a formatted markdown list
   of all edits (label, source location, note) to the clipboard.

## Configuration

`WidgetationConfig` (all fields optional):

| field                   | default              | meaning                                            |
| ----------------------- | -------------------- | -------------------------------------------------- |
| `mode`                  | `WidgetationMode.edit` | `none` to disable, `edit` to mount the inspector |
| `selectButtonAlignment` | `Alignment.bottomRight` | where the floating toolbar docks                |
| `enabled`               | `true`               | hard kill switch; combined with `kReleaseMode`     |

## Limits / known gaps

- Property summaries surfaced on the picked node are best-effort
  `toDescription()` strings, capped to 16 per node.
