import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Light palette (Deep blue-purple tones) ─────────────────────
  static const Color _lightBg = Color(0xFFF0F3F8);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF1B1D2A);
  static const Color _lightTextSecondary = Color(0xFF6B6F82);
  static const Color _lightAccent = Color(0xFF5C5FE0);
  static const Color _lightDialRing = Color(0xFFD5D8E4);

  // ─── Dark palette (Rich deep navy-purple) ───────────────────────
  static const Color _darkBg = Color(0xFF07080F);
  static const Color _darkSurface = Color(0xFF151728);
  static const Color _darkTextPrimary = Color(0xFFF2F3F8);
  static const Color _darkTextSecondary = Color(0xFF8A8FA5);
  static const Color _darkAccent = Color(0xFF8B8EFF);
  static const Color _darkDialRing = Color(0xFF252840);

  // ─── Gradient colors (Background mesh) ──────────────────────────
  static const Color darkGradient1 = Color(0xFF07080F);
  static const Color darkGradient2 = Color(0xFF230C46);
  static const Color darkGradient3 = Color(0xFF0A1F44);
  static const Color darkGlow1 = Color(0xFF6B2FB8);
  static const Color darkGlow2 = Color(0xFF1963B5);

  static const Color lightGradient1 = Color(0xFFF0F3F8);
  static const Color lightGradient2 = Color(0xFFDDE2F0);
  static const Color lightGradient3 = Color(0xFFEFE8F6);
  static const Color lightGlow1 = Color(0xFFACA6E8);
  static const Color lightGlow2 = Color(0xFF94C4EB);

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
