import 'package:flutter/material.dart';
import 'package:pet_profile_app/theme/themes/color_scheme_theme.dart';

class CInputDecorationTheme {
  CInputDecorationTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    hintStyle: TextStyle(
      color: CColorThemes.lightScheme.onPrimary, 
      decoration: TextDecoration.underline,
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: CColorThemes.lightScheme.onSurface, width: 1.0),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    hintStyle: TextStyle(
      color: CColorThemes.darkScheme.onPrimary,
      decoration: TextDecoration.underline,
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: CColorThemes.darkScheme.onSurface, width: 1.0),
    ),
  );
}
