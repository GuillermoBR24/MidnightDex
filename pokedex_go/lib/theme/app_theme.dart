import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores azul oscuro estilo Pokémon GO
  static const Color bgDark       = Color(0xFF0A0E1A);
  static const Color bgCard       = Color(0xFF111827);
  static const Color bgSurface    = Color(0xFF1A2333);
  static const Color accentBlue   = Color(0xFF00B4FF);
  static const Color accentCyan   = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFF6C63FF);
  static const Color textPrimary  = Color(0xFFE8F4FF);
  static const Color textSecond   = Color(0xFF8FAABB);
  static const Color borderColor  = Color(0xFF1E3A5F);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: accentBlue,
      secondary: accentCyan,
      surface: bgSurface,
      background: bgDark,
    ),
    textTheme: GoogleFonts.exo2TextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.exo2(
        color: textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
      titleLarge: GoogleFonts.exo2(
        color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.exo2(color: textSecond, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      titleTextStyle: GoogleFonts.exo2(
        color: textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
      iconTheme: const IconThemeData(color: accentBlue),
    ),
    cardTheme: CardTheme(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),
  );

  // Colores por tipo de Pokémon
  static const Map<String, Color> typeColors = {
    'Normal':   Color(0xFF9E9E9E),
    'Fire':     Color(0xFFFF6B35),
    'Water':    Color(0xFF2196F3),
    'Electric': Color(0xFFFFD600),
    'Grass':    Color(0xFF4CAF50),
    'Ice':      Color(0xFF80DEEA),
    'Fighting': Color(0xFFE53935),
    'Poison':   Color(0xFFAB47BC),
    'Ground':   Color(0xFFD4A017),
    'Flying':   Color(0xFF90CAF9),
    'Psychic':  Color(0xFFE91E8C),
    'Bug':      Color(0xFF8BC34A),
    'Rock':     Color(0xFF8D6E63),
    'Ghost':    Color(0xFF5C6BC0),
    'Dragon':   Color(0xFF3F51B5),
    'Dark':     Color(0xFF37474F),
    'Steel':    Color(0xFFB0BEC5),
    'Fairy':    Color(0xFFF48FB1),
  };

  static Color getTypeColor(String type) =>
      typeColors[type] ?? const Color(0xFF9E9E9E);
}