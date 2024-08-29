import 'package:flutter/material.dart';
import 'package:pet_profile_app/theme/themes/color_scheme_theme.dart';

class CInputDecorationTheme {
  CInputDecorationTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    hintStyle: TextStyle(color: lightScheme.onPrimary),
  );
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    hintStyle: TextStyle(color: darkScheme.onPrimary),
  );
}
