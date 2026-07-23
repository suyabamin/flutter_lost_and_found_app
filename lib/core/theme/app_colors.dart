import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors from DESIGN.md
  static const Color primary = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);

  static const Color secondary = Color(0xFF00687A);
  static const Color secondaryContainer = Color(0xFF57DFFE);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF006172);

  static const Color tertiary = Color(0xFF006056);
  static const Color tertiaryContainer = Color(0xFF007B6E);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF7F9FB);
  static const Color onBackground = Color(0xFF191C1E);

  static const Color surface = Color(0xFFF7F9FB);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color surfaceVariant = Color(0xFFE0E3E5);
  static const Color onSurfaceVariant = Color(0xFF434655);

  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkSurfaceVariant = Color(0xFF334155);

  // Glassmorphism Tint Colors
  static const Color glassLightBg = Color(0xCCFFFFFF);
  static const Color glassDarkBg = Color(0x990F172A);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x22FFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF004AC6), Color(0xFF00687A), Color(0xFF006056)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
