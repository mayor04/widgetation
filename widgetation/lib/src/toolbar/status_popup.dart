import 'package:flutter/widgets.dart';

import '../state/preferences_store.dart';
import '../state/widgetation_store.dart';
import '../theme.dart';
import 'toolbar_icons.dart';
import 'wordmark_painter.dart';

/// Card surfaced above the toolbar via [OverlayPortal] when the user taps
/// the gear button. Hosts the brand header (wordmark + version + theme
/// toggle), the marker color picker, and the clear-on-copy/send toggle.
class ToolbarStatusPopup extends StatelessWidget {
  final VoidCallback onDismiss;

  const ToolbarStatusPopup({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 65,
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(blurRadius: 8, offset: const Offset(0, 2), color: theme.shadow),
                BoxShadow(blurRadius: 16, offset: const Offset(0, 4), color: theme.shadow),
              ],
            ),
            child: StoreBuilder<PreferencesStore, PreferencesState>(
              builder: (context, prefs) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BrandHeader(prefs: prefs),
                    SizedBox(height: 14),
                    _Divider(color: theme.divider),
                    SizedBox(height: 14),
                    _MarkerColorSection(prefs: prefs),
                    SizedBox(height: 14),
                    _Divider(color: theme.divider),
                    SizedBox(height: 12),
                    _ClearOnCopyRow(prefs: prefs),
                    SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) => Container(height: 1, color: color);
}

class _BrandHeader extends StatelessWidget {
  final PreferencesState prefs;
  const _BrandHeader({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    final isDark = prefs.themeMode == WidgetationThemeMode.dark;
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 28,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(Color(0xFF6AC1EA), BlendMode.srcIn),
            child: CustomPaint(painter: WidgetationWordmarkPainter(color: theme.onSurface)),
          ),
        ),
        const Spacer(),
        Text(
          'v$kWidgetationVersion',
          style: TextStyle(color: theme.onSurfaceMuted, fontSize: 10, fontWeight: FontWeight.w500),
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(width: 10),
        _IconButton(
          icon: isDark ? ToolbarIcon.sun : ToolbarIcon.moon,
          onTap: () => context.read<PreferencesStore>().setThemeMode(
            isDark ? WidgetationThemeMode.light : WidgetationThemeMode.dark,
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatefulWidget {
  final ToolbarIcon icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hover = false;
  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hover ? theme.onSurface.withAlpha(28) : null,
          ),
          child: CustomPaint(
            painter: ToolbarIconPainter(
              icon: widget.icon,
              color: theme.onSurface,
              strokeWidth: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkerColorSection extends StatelessWidget {
  final PreferencesState prefs;
  const _MarkerColorSection({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marker Color',
          style: TextStyle(color: theme.onSurfaceMuted, fontSize: 11, fontWeight: FontWeight.w500),
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < kMarkerPalette.length; i++)
              _Swatch(
                color: kMarkerPalette[i],
                selected: prefs.markerColorIndex == i,
                onTap: () => context.read<PreferencesStore>().setMarkerColorIndex(i),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _Swatch({required this.color, required this.selected, required this.onTap});

  static const double _size = 20;
  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: _size + _ring * 2 + 2,
          height: _size + _ring * 2 + 2,
          child: Center(
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? null : color,
                border: selected ? Border.all(color: color, width: _ring) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearOnCopyRow extends StatefulWidget {
  final PreferencesState prefs;
  const _ClearOnCopyRow({required this.prefs});

  @override
  State<_ClearOnCopyRow> createState() => _ClearOnCopyRowState();
}

class _ClearOnCopyRowState extends State<_ClearOnCopyRow> {
  bool _helpOpen = false;

  void _toggleHelp() => setState(() => _helpOpen = !_helpOpen);

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    final on = widget.prefs.clearOnCopy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: _Checkbox(
                checked: on,

                onTap: () => context.read<PreferencesStore>().setClearOnCopy(!on),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.read<PreferencesStore>().setClearOnCopy(!on),
                child: Text(
                  'Clear on copy/send',
                  style: TextStyle(
                    color: theme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleHelp,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CustomPaint(
                  painter: ToolbarIconPainter(
                    icon: ToolbarIcon.help,
                    color: _helpOpen ? theme.onSurface : theme.onSurfaceMuted,
                    strokeWidth: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_helpOpen) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Clears all selections and edits after copying. '
              'Will also apply to the future Send action.',
              style: TextStyle(color: theme.onSurfaceMuted, fontSize: 11, height: 1.35),
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  const _Checkbox({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetationTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: checked ? theme.accent : const Color(0x00000000),
            border: Border.all(color: checked ? theme.accent : theme.onSurfaceMuted, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: checked
              ? CustomPaint(
                  painter: ToolbarIconPainter(
                    icon: ToolbarIcon.check,
                    color: theme.onAccent,
                    strokeWidth: 2.4,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

