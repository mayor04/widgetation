import 'package:flutter/material.dart';

/// Apple desktop-app design tokens — small, soft, native-mac scale.
/// Single Action Blue accent, translucent sidebar, hairline dividers.
class AppColors {
  // Brand & accent
  static const primary = Color(0xFF0066CC);
  static const primaryFocus = Color(0xFF0071E3);
  static const primaryOnDark = Color(0xFF2997FF);

  // Surface
  static const canvas = Color(0xFFFFFFFF);
  static const canvasParchment = Color(0xFFF5F5F7);
  static const surfacePearl = Color(0xFFFAFAFC);
  static const sidebar = Color(0xFFE9E9EC);
  static const sidebarHover = Color(0xFFDDDDE0);
  static const titlebar = Color(0xFFE8E8EB);
  static const surfaceTile1 = Color(0xFF272729);
  static const surfaceTile2 = Color(0xFF2A2A2C);
  static const surfaceTile3 = Color(0xFF1E1E20);

  // Text
  static const ink = Color(0xFF1D1D1F);
  static const body = Color(0xFF2C2C2E);
  static const bodyOnDark = Color(0xFFFFFFFF);
  static const bodyMuted = Color(0xFFCCCCCC);
  static const inkMuted80 = Color(0xFF333333);
  static const inkMuted48 = Color(0xFF7A7A7A);
  static const inkMuted32 = Color(0xFFA1A1A6);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onDark = Color(0xFFFFFFFF);

  // Hairlines
  static const dividerSoft = Color(0xFFEDEDF0);
  static const hairline = Color(0xFFD1D1D6);
  static const hairlineSoft = Color(0xFFE5E5EA);

  // Traffic lights
  static const trafficClose = Color(0xFFFF5F57);
  static const trafficMin = Color(0xFFFEBC2E);
  static const trafficMax = Color(0xFF28C840);

  // Code mockup (dark snippets)
  static const codePunct = Color(0xFF8E8E93);
  static const codeKeyword = Color(0xFFFF7AB6);
  static const codeString = Color(0xFFFD8D3C);
  static const codeIdent = Color(0xFFA1F0FF);
  static const codeComment = Color(0xFF7A7A7A);
  static const codeText = Color(0xFFE6E6E8);
}

class AppSpacing {
  static const xxs = 2.0;
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const xxl = 40.0;
}

class AppRadius {
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const pill = 9999.0;
}

/// SF Pro Text on Apple platforms; system-sans fallback elsewhere.
/// Small, native-mac scale — body sits at 13px, not 17px.
class AppType {
  static const _display = '.SF Pro Display';
  static const _text = '.SF Pro Text';
  static const _mono = 'Menlo';
  static const _fallback = <String>['Helvetica Neue', 'Arial', 'sans-serif'];

  /// Section H1 inside the detail pane (e.g. "Overview").
  static const titleXl = TextStyle(
    fontFamily: _display,
    fontFamilyFallback: _fallback,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.18,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );

  /// Detail pane subtitle.
  static const titleLg = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );

  /// Card / panel heading.
  static const titleMd = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.08,
    color: AppColors.ink,
  );

  /// Body text — the default app reading size.
  static const body = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: -0.08,
    color: AppColors.body,
  );

  static const bodyStrong = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.08,
    color: AppColors.ink,
  );

  /// Sidebar row label.
  static const sidebar = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.08,
    color: AppColors.ink,
  );

  /// Sidebar group header — uppercase tiny.
  static const sidebarGroup = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.6,
    color: AppColors.inkMuted48,
  );

  static const caption = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.06,
    color: AppColors.inkMuted48,
  );

  static const captionStrong = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.inkMuted80,
  );

  /// Toolbar button label.
  static const toolbar = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.06,
    color: AppColors.ink,
  );

  /// Window title centered in titlebar.
  static const windowTitle = TextStyle(
    fontFamily: _text,
    fontFamilyFallback: _fallback,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.06,
    color: AppColors.ink,
  );

  static const code = TextStyle(
    fontFamily: _mono,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.codeText,
  );
}
