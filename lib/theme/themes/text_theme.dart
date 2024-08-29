import 'package:flutter/material.dart';
import 'package:pet_profile_app/theme/themes/color_scheme_theme.dart';

class CTextTheme {
  CTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: CColorThemes.lightTextColor),
    headlineMedium: const TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w600, color: CColorThemes.lightTextColor),
    headlineSmall: const TextStyle().copyWith(fontSize: 18.0, fontWeight: FontWeight.w600, color: CColorThemes.lightTextColor),

    titleLarge: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: CColorThemes.lightTextColor),
    titleMedium: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: CColorThemes.lightTextColor),
    titleSmall: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: CColorThemes.lightTextColor),

    bodyLarge: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: CColorThemes.lightTextColor),
    bodyMedium: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: CColorThemes.lightTextColor),
    bodySmall: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: CColorThemes.lightTextColor.withOpacity(0.5)),

    labelLarge: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: CColorThemes.lightTextColor),
    labelMedium: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: CColorThemes.lightTextColor.withOpacity(0.5)),
    labelSmall: const TextStyle().copyWith(fontSize: 10.0, fontWeight: FontWeight.normal, color: CColorThemes.lightTextColor.withOpacity(0.5)),
  );
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(fontSize: 32.0, fontWeight: FontWeight.bold, color: CColorThemes.darkTextColor),
    headlineMedium: const TextStyle().copyWith(fontSize: 24.0, fontWeight: FontWeight.w600, color: CColorThemes.darkTextColor),
    headlineSmall: const TextStyle().copyWith(fontSize: 18.0, fontWeight: FontWeight.w600, color: CColorThemes.darkTextColor),

    titleLarge: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w600, color: CColorThemes.darkTextColor),
    titleMedium: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w500, color: CColorThemes.darkTextColor),
    titleSmall: const TextStyle().copyWith(fontSize: 16.0, fontWeight: FontWeight.w400, color: CColorThemes.darkTextColor),

    bodyLarge: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: CColorThemes.darkTextColor),
    bodyMedium: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.normal, color: CColorThemes.darkTextColor),
    bodySmall: const TextStyle().copyWith(fontSize: 14.0, fontWeight: FontWeight.w500, color: CColorThemes.darkTextColor.withOpacity(0.5)),

    labelLarge: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: CColorThemes.darkTextColor),
    labelMedium: const TextStyle().copyWith(fontSize: 12.0, fontWeight: FontWeight.normal, color: CColorThemes.darkTextColor.withOpacity(0.5)),
    labelSmall: const TextStyle().copyWith(fontSize: 10.0, fontWeight: FontWeight.normal, color: CColorThemes.darkTextColor.withOpacity(0.5)),
  );
}