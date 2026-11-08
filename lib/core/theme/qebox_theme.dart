import 'package:flutter/material.dart';

abstract final class QeboxPalette {
  static const green = Color(0xFF064E42);
  static const deepGreen = Color(0xFF003B32);
  static const orange = Color(0xFFFF7417);
  static const ink = Color(0xFF17201E);
  static const background = Color(0xFFF8F7F2);
  static const mint = Color(0xFFE4F1EC);
  static const peach = Color(0xFFFFE9DA);
  static const line = Color(0xFFE7E8E3);
  static const muted = Color(0xFF75807D);
}

ThemeData buildQeboxTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: QeboxPalette.orange,
    primary: QeboxPalette.orange,
    secondary: QeboxPalette.green,
    surface: QeboxPalette.background,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: QeboxPalette.background,
    dividerColor: QeboxPalette.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: QeboxPalette.background,
      foregroundColor: QeboxPalette.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: QeboxPalette.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: QeboxPalette.deepGreen,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: QeboxPalette.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: QeboxPalette.orange,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QeboxPalette.deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: QeboxPalette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: QeboxPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: QeboxPalette.orange, width: 1.5),
      ),
    ),
  );
}
