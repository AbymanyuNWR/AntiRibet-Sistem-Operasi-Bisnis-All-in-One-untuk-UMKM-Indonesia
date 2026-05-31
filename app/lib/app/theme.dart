import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Design Tokens: Professional Warmth
  static const Color primaryColor = Color(0xFF0052CC); // Blue
  static const Color accentColor = Color(0xFF00B8D9); // Teal
  static const Color successColor = Color(0xFF36B37E); // Green
  static const Color warningColor = Color(0xFFFF8B00); // Amber
  static const Color errorColor = Color(0xFFDE350B); // Red
  static const Color neutralBackground = Color(0xFFF4F5F7); // Light gray

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: neutralBackground,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.syne(fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: GoogleFonts.syne(fontWeight: FontWeight.bold, color: Colors.black87),
        displaySmall: GoogleFonts.syne(fontWeight: FontWeight.bold, color: Colors.black87),
        headlineLarge: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.black87),
        headlineMedium: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.black87),
        titleLarge: GoogleFonts.syne(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // medium radius
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // medium radius
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
