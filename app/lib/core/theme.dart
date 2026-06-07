import 'package:flutter/material.dart';

class AppTheme {
  static const _lightPrimary = Color(0xFF2592EB);
  static const _lightBackground = Color(0xFFF8FAFC);
  static const _lightSurface = Colors.white;
  static const _lightText = Color(0xFF0F172A);

  static const _darkPrimary = Color(0xFF3BB2F6);
  static const _darkBackground = Color(0xFF0B1220);
  static const _darkSurface = Color(0xFF111827);
  static const _darkText = Color(0xFFE5E7EB);

  static const _error = Color(0xFFEC3528);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightBackground,
      surface: _lightSurface,
      onPrimary: Colors.white,
      onSecondary: _lightText,
      onSurface: _lightText,
      error: _error,
    ),

    scaffoldBackgroundColor: _lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _error, width: 1.6),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkBackground,
      surface: _darkSurface,
      onPrimary: Colors.white,
      onSecondary: _darkText,
      onSurface: _darkText,
      error: _error,
    ),

    scaffoldBackgroundColor: _darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _error, width: 1.6),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}
