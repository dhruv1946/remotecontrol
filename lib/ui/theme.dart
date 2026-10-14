import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Pure Black & White Palette ────────────────────────────────────────
  static const Color bg           = Color(0xFF000000); // pitch black
  static const Color surface      = Color(0xFF111111); // deep card surface
  static const Color surfaceMid   = Color(0xFF1A1A1A); // elevated surface
  static const Color surfaceHi    = Color(0xFF262626); // hover / highlight bg
  static const Color border       = Color(0xFF222222); // subtle border
  static const Color borderBright = Color(0xFF404040); // visible border

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF); // crisp white
  static const Color textSecondary = Color(0xFFA0A0A0); // clean neutral grey
  static const Color textDim       = Color(0xFF555555); // muted dark grey

  // ── Monochrome Accents ────────────────────────────────────────────────
  static const Color white         = Color(0xFFFFFFFF);
  static const Color whiteDim      = Color(0xFFD4D4D4);
  static const Color cyan          = Color(0xFFFFFFFF); // compatibility alias
  static const Color green         = Color(0xFFFFFFFF); // compatibility alias

  // Gradient for active mode card (Pure White to Crisp Off-White)
  static const LinearGradient activeGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFEBEBEB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows / glows (Crisp White Glow) ────────────────────────────────
  static List<BoxShadow> cyanGlow({double intensity = 1.0}) => whiteGlow(intensity: intensity);

  static List<BoxShadow> whiteGlow({double intensity = 1.0}) => [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.16 * intensity),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.70),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Typography ───────────────────────────────────────────────────────
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
    const TextTheme(
      displayLarge : TextStyle(fontSize: 96, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -4, height: 1),
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5),
      titleLarge   : TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium  : TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      bodyMedium   : TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
      labelLarge   : TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
      labelMedium  : TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.5),
      labelSmall   : TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textDim, letterSpacing: 0.8),
    ),
  );

  // ── ThemeData ─────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: white,
      surface: surface,
    ),
    textTheme: textTheme,
  );
}
