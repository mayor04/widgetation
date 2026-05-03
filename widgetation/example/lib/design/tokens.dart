import 'package:flutter/material.dart';

/// Ochestra design tokens — blue + white + deep navy.
class AppColors {
  // Brand
  static const primary = Color(0xFF6AC1EA);
  static const primaryActive = Color(0xFF4DA8D2);
  static const primaryDisabled = Color(0xFFD1E7F2);
  static const accentTeal = Color(0xFF5DB8A6);
  static const accentAmber = Color(0xFFE8A55A);

  // Surfaces — white canvas with cool blue tints
  static const canvas = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF5F8FB);
  static const surfaceCard = Color(0xFFEAF2F8);
  static const surfaceStrong = Color(0xFFDCE9F2);
  static const surfaceDark = Color(0xFF0F1B2D);
  static const surfaceDarkElevated = Color(0xFF1A2638);
  static const surfaceDarkSoft = Color(0xFF15212F);
  static const hairline = Color(0xFFE1E8EE);
  static const hairlineSoft = Color(0xFFEEF2F6);

  // Text
  static const ink = Color(0xFF0F1B2D);
  static const bodyStrong = Color(0xFF1E2B3D);
  static const body = Color(0xFF3A4658);
  static const muted = Color(0xFF6B7585);
  static const mutedSoft = Color(0xFF8E96A4);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onDark = Color(0xFFFFFFFF);
  static const onDarkSoft = Color(0xFF98A2B0);

  // Semantic
  static const success = Color(0xFF5DB872);
  static const warning = Color(0xFFD4A017);
  static const error = Color(0xFFC64545);

  // Syntax (for the dark code mockup)
  static const codeKeyword = Color(0xFF6AC1EA);
  static const codeString = Color(0xFFE8A55A);
  static const codeFunction = Color(0xFF5DB8A6);
  static const codeComment = Color(0xFF6B7585);
  static const codeText = Color(0xFFD9DCE2);
}

class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const section = 96.0;
}

class AppRadius {
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const pill = 9999.0;
}

/// Slab-serif display (Copernicus substitute) + humanist sans body.
class AppType {
  // Substitute fallbacks: serif → system serif; sans → system sans.
  static const _serif = 'Georgia';
  static const _sans = 'Helvetica Neue';
  static const _mono = 'Menlo';

  static const displayXl = TextStyle(
    fontFamily: _serif,
    fontSize: 64,
    fontWeight: FontWeight.w400,
    height: 1.05,
    letterSpacing: -1.5,
    color: AppColors.ink,
  );
  static const displayLg = TextStyle(
    fontFamily: _serif,
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.1,
    letterSpacing: -1,
    color: AppColors.ink,
  );
  static const displayMd = TextStyle(
    fontFamily: _serif,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.15,
    letterSpacing: -0.5,
    color: AppColors.ink,
  );
  static const displaySm = TextStyle(
    fontFamily: _serif,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static const titleLg = TextStyle(
    fontFamily: _sans,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.ink,
  );
  static const titleMd = TextStyle(
    fontFamily: _sans,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.ink,
  );
  static const titleSm = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.ink,
  );

  static const bodyMd = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.body,
  );
  static const bodySm = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.body,
  );

  static const caption = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.muted,
  );
  static const captionUppercase = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 1.5,
    color: AppColors.muted,
  );

  static const code = TextStyle(
    fontFamily: _mono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.codeText,
  );

  static const button = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const navLink = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.ink,
  );
}
