
import 'package:flutter/material.dart';
import 'package:pet_profile_app/theme/themes/color_scheme_theme.dart';



class CTextSelectionThemes {
  CTextSelectionThemes._();

  static TextSelectionThemeData lightTextSelectionThemeData = TextSelectionThemeData(
    cursorColor: CColorThemes.lightTextColor,
    selectionColor: CColorThemes.darkTextColor,
    selectionHandleColor: CColorThemes.lightTextColor,
  );

  static TextSelectionThemeData darkTextSelectionThemeData = TextSelectionThemeData(
    cursorColor: CColorThemes.darkTextColor,
    selectionColor: CColorThemes.lightTextColor,
    selectionHandleColor: CColorThemes.darkTextColor,
  );
}