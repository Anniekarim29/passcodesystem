import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Light palette ──────────────────────────────────────────────
  static const Color _lightBg = Color(0xFFF2F2F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF1C1C1E);
  static const Color _lightTextSecondary = Color(0xFF8E8E93);
  static const Color _lightAccent = Color(0xFF3A3A3C);
  static const Color _lightDialRing = Color(0xFFE5E5EA);

  // ─── Dark palette ──────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF1C1C1E);
  static const Color _darkSurface = Color(0xFF2C2C2E);
  static const Color _darkTextPrimary = Color(0xFFF2F2F7);
  static const Color _darkTextSecondary = Color(0xFF8E8E93);
  static const Color _darkAccent = Color(0xFFD1D1D6);
  static const Color _darkDialRing = Color(0xFF3A3A3C);

  // ─── Feedback colours ──────────────────────────────────────────
  static const Color successGreen = Color(0xFF34C759);
  static const Color errorRed = Color(0xFFFF3B30);

  // ─── Neumorphic helpers ────────────────────────────────────────
  static List<BoxShadow> neumorphicLight({double blur = 12, double offset = 4}) {
    return [
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.8),
        blurRadius: blur,
        offset: Offset(-offset, -offset),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: blur,
        offset: Offset(offset, offset),
      ),
    ];
  }

  static List<BoxShadow> neumorphicDark({double blur = 12, double offset = 4}) {
    return [
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.05),
        blurRadius: blur,
        offset: Offset(-offset, -offset),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: blur,
        offset: Offset(offset, offset),
      ),
    ];
  }

  // ─── Theme data builders ──────────────────────────────────────
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBg,
      colorScheme: const ColorScheme.light(
        surface: _lightSurface,
        primary: _lightAccent,
        onSurface: _lightTextPrimary,
        secondary: _lightTextSecondary,
        outline: _lightDialRing,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _lightTextPrimary,
            letterSpacing: -0.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _lightTextSecondary,
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      colorScheme: const ColorScheme.dark(
        surface: _darkSurface,
        primary: _darkAccent,
        onSurface: _darkTextPrimary,
        secondary: _darkTextSecondary,
        outline: _darkDialRing,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _darkTextPrimary,
            letterSpacing: -0.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _darkTextSecondary,
          ),
        ),
      ),
    );
  }
}
