import 'package:flutter/material.dart';

/// AJ's brand palette.
/// Deep forest green + brass gold on warm cream paper,
/// from the official design tokens (css/tokens.css).
class Brand {
  static const Color green950 = Color(0xFF03201A);
  static const Color green900 = Color(0xFF063A2A);
  static const Color green800 = Color(0xFF0B513B);
  static const Color green700 = Color(0xFF126248);
  static const Color green600 = Color(0xFF197355);
  static const Color green100 = Color(0xFFE0EFE8);
  static const Color green50 = Color(0xFFF1F7F3);

  static const Color gold700 = Color(0xFF8A6508);
  static const Color gold600 = Color(0xFFC49A3C);
  static const Color gold500 = Color(0xFFD4AC4F);
  static const Color gold400 = Color(0xFFE0C07A);
  static const Color gold100 = Color(0xFFF7EED6);
  static const Color gold50 = Color(0xFFFCF8EC);

  static const Color ink = Color(0xFF1C211F);
  static const Color ink2 = Color(0xFF414B46);
  static const Color ink3 = Color(0xFF6B756F);
  static const Color line = Color(0xFFD9DFDA);
  static const Color lineSoft = Color(0xFFE9EDE9);
  static const Color paper = Color(0xFFF7F5EF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color ok = Color(0xFF227D5B);
  static const Color danger = Color(0xFFA3312B);
}

ThemeData buildBrandTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Brand.green700,
    brightness: Brightness.light,
    primary: Brand.green700,
    onPrimary: Colors.white,
    secondary: Brand.gold600,
    onSecondary: Colors.white,
    surface: Brand.surface,
    onSurface: Brand.ink,
    error: Brand.danger,
    // Warm cream canvas to evoke a government document.
  ).copyWith(
    surface: Brand.surface,
    onSurface: Brand.ink,
    surfaceContainerLowest: Brand.surface,
    surfaceContainerLow: Brand.paper,
    surfaceContainer: Brand.lineSoft,
    surfaceContainerHigh: Brand.line,
    surfaceContainerHighest: Brand.green50,
    outline: Brand.ink3,
    outlineVariant: Brand.line,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Brand.paper,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Brand.green900,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardTheme(
      color: Brand.surface,
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: Brand.lineSoft),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Brand.green50,
      side: BorderSide(color: Brand.line),
      labelStyle: TextStyle(color: Brand.ink2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.green700,
        foregroundColor: Colors.white,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: Brand.green100,
        foregroundColor: Brand.green800,
      ),
    ),
  );
}
