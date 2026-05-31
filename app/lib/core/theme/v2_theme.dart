import 'package:flutter/material.dart';
import 'v2_colors.dart';
import 'v2_typography.dart';

class V2Theme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: V2Colors.primaryBlue,
      scaffoldBackgroundColor: V2Colors.pageBackground,
      colorScheme: const ColorScheme.light(
        primary: V2Colors.primaryBlue,
        secondary: V2Colors.accentTeal,
        error: V2Colors.errorRed,
        surface: V2Colors.cardBackground,
        background: V2Colors.pageBackground,
      ),
      textTheme: TextTheme(
        displayLarge: V2Typography.display.copyWith(fontSize: 56),
        displayMedium: V2Typography.display.copyWith(fontSize: 40),
        headlineLarge: V2Typography.headingXl,
        headlineMedium: V2Typography.headingLg,
        headlineSmall: V2Typography.headingMd,
        titleLarge: V2Typography.headingSm,
        bodyLarge: V2Typography.bodyLg,
        bodyMedium: V2Typography.bodyMd,
        bodySmall: V2Typography.bodySm,
        labelLarge: V2Typography.labelLg,
        labelMedium: V2Typography.labelMd,
        labelSmall: V2Typography.labelSm,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: V2Colors.cardBackground,
        foregroundColor: V2Colors.primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: V2Typography.headingMd,
        iconTheme: const IconThemeData(color: V2Colors.primaryText),
      ),
      dividerTheme: const DividerThemeData(
        color: V2Colors.divider,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: V2Colors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: V2Colors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: V2Colors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: V2Colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: V2Colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: V2Colors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: V2Colors.errorRed),
        ),
        labelStyle: V2Typography.bodyMd.copyWith(color: V2Colors.secondaryText),
        hintStyle: V2Typography.bodyMd.copyWith(color: V2Colors.mutedText),
      ),
    );
  }
}
