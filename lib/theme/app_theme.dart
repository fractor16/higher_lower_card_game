import 'package:flutter/material.dart';

class AppTheme {
  // Background gradient colors (Deep Casino Felt / Emerald Midnight)
  static const Color backgroundTop = Color(0xFF0F382A);
  static const Color backgroundBottom = Color(0xFF071B14);
  static const Color backgroundRadial = Color(0xFF144D3A);

  // Accent & Metallic colors
  static const Color gold = Color(0xFFFFD15C);
  static const Color goldDark = Color(0xFFC89526);
  static const Color goldLight = Color(0xFFFFF0B8);

  // Card colors
  static const Color cardFront = Color(0xFFFDFDFD);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x66000000);
  static const Color cardBackBase = Color(0xFF1A365D);
  static const Color cardBackAccent = Color(0xFFD69E2E);

  // Action Button Colors
  static const Color higherGreen = Color(0xFF10B981);
  static const Color higherGreenDark = Color(0xFF047857);
  static const Color higherGlow = Color(0x5510B981);

  static const Color lowerRed = Color(0xFFEF4444);
  static const Color lowerRedDark = Color(0xFFB91C1C);
  static const Color lowerGlow = Color(0x55EF4444);

  // Status Colors
  static const Color correctGreen = Color(0xFF22C55E);
  static const Color wrongRed = Color(0xFFF43F5E);
  static const Color tieAmber = Color(0xFFF59E0B);

  // Glassmorphic containers
  static const Color glassSurface = Color(0x28FFFFFF);
  static const Color glassBorder = Color(0x38FFFFFF);
  static const Color glassSurfaceDark = Color(0x55000000);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundBottom,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: higherGreen,
        surface: backgroundTop,
      ),
      fontFamily: 'Roboto',
    );
  }
}
