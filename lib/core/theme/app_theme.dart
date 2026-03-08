import 'package:flutter/material.dart';
import 'package:sigetu/core/theme/appointment_context_palette.dart';

class AppTheme {
  // LIGHT COLORS
  static const Color _primary = Color(0xFF2F6FED);
  static const Color _primaryLight = Color(0xFF5A8FF5);
  static const Color _background = Color(0xFFF4F8FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFC9D8FF);
  static const Color _textPrimary = Color(0xFF1A2B4C);
  static const Color _textSecondary = Color(0xFF4A5A7A);

  // DARK COLORS
  static const Color _darkPrimary = Color(0xFF6EA8FE);
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkBorder = Color(0xFF334155);
  static const Color _darkTextPrimary = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);

  // Tema claro
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _primaryLight,
      onSecondary: Colors.white,
      error: Color(0xFFD64545),
      onError: Colors.white,
      surface: _surface,
      onSurface: _textPrimary,
    ),

    scaffoldBackgroundColor: _background,

    appBarTheme: const AppBarTheme(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: _primary,
      iconColor: _primary,
      filled: true,
      fillColor: const Color(0xFFF0F5FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        elevation: 0,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _textPrimary),
      bodyMedium: TextStyle(color: _textSecondary),
    ),

    extensions: const <ThemeExtension<dynamic>>[
      AppointmentContextPalette.defaults,
    ],
  );

  // Tema oscuro
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _primary,
      onPrimary: Colors.black,
      secondary: _darkPrimary,
      onSecondary: Colors.black,
      error: Color(0xFFD64545),
      onError: Colors.white,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
    ),

    scaffoldBackgroundColor: _darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      foregroundColor: _darkTextPrimary,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: _darkPrimary,
      iconColor: _darkPrimary,
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.black,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        elevation: 0,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _darkTextPrimary),
      bodyMedium: TextStyle(color: _darkTextSecondary),
    ),

    extensions: const <ThemeExtension<dynamic>>[
      AppointmentContextPalette.defaults,
    ],
  );
}
