import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'v2_colors.dart';

class V2Typography {
  // --- UI & Body (Plus Jakarta Sans) ---
  static TextStyle get bodyBase => GoogleFonts.plusJakartaSans(
        color: V2Colors.primaryText,
      );

  // Headings
  static TextStyle get headingXl => bodyBase.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );
  static TextStyle get headingLg => bodyBase.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );
  static TextStyle get headingMd => bodyBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );
  static TextStyle get headingSm => bodyBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // Body
  static TextStyle get bodyLg => bodyBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );
  static TextStyle get bodyMd => bodyBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );
  static TextStyle get bodySm => bodyBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: V2Colors.secondaryText,
        height: 1.5,
      );

  // Labels
  static TextStyle get labelLg => bodyBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get labelMd => bodyBase.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );
  static TextStyle get labelSm => bodyBase.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ); // Usually uppercase

  // Numeric (Tabular Figures)
  // Plus Jakarta Sans supports tabular figures out of the box via features, 
  // but standard fontFeatures works perfectly.
  static TextStyle get numericXl => bodyBase.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  static TextStyle get numericLg => bodyBase.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
  static TextStyle get numericMd => bodyBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // --- Display (Syne) ---
  static TextStyle get display => GoogleFonts.syne(
        color: V2Colors.primaryText,
        fontWeight: FontWeight.w800,
      );
}
