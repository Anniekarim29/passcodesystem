import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Light palette ──────────────────────────────────────────────
  static const Color _lightBg = Color(0xFFF8F9FF);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF1A1C1E);
  static const Color _lightTextSecondary = Color(0xFF6C7075);
  static const Color _lightAccent = Color(0xFF4A4E69);
  static const Color _lightDialRing = Color(0xFFE2E4EB);

  // ─── Dark palette ──────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF0F1115);
  static const Color _darkSurface = Color(0xFF1A1C22);
  static const Color _darkTextPrimary = Color(0xFFF0F2F5);
  static const Color _darkTextSecondary = Color(0xFF9EA4AD);
  static const Color _darkAccent = Color(0xFF9BA2FF);
  static const Color _darkDialRing = Color(0xFF2D3139);

  // ─── Feedback colours ──────────────────────────────────────────
  static const Color successGreen = Color(0xFF00D180);
  static const Color errorRed = Color(0xFFFF4D4D);

  // ─── Neumorphic helpers ────────────────────────────────────────
  static List<BoxShadow> neumorphicLight({double blur = 12, double offset = 4}) {
    return [
      BoxShadow(
        color: Colors.white,
        blurRadius: blur,
        offset: Offset(-offset, -offset),
      ),
      BoxShadow(
        color: const Color(0xFFD1D9E6).withValues(alpha: 0.8),
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
        color: Colors.black.withValues(alpha: 0.45),
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
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: _lightTextPrimary,
            letterSpacing: -1.0,
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
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: _darkTextPrimary,
            letterSpacing: -1.0,
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
