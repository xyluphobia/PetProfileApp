import 'package:flutter/material.dart';
import 'package:pet_profile_app/theme/themes/app_bar_theme.dart';
import 'package:pet_profile_app/theme/themes/bottom_navigation_bar_theme.dart';
import 'package:pet_profile_app/theme/themes/color_scheme_theme.dart';
import 'package:pet_profile_app/theme/themes/input_decoration_theme.dart';
import 'package:pet_profile_app/theme/themes/text_selection_theme.dart';
import 'package:pet_profile_app/theme/themes/text_theme.dart';

class ThemeManager
{
  static ThemeManager? _instance;
  static ThemeManager get instance {
    _instance ??= ThemeManager._init();

    return _instance!;
  }

  ThemeManager._init() {
    theme.value = lightTheme;
  }

  ValueNotifier<ThemeData> theme = ValueNotifier<ThemeData>(ThemeData.light());
  ValueNotifier<bool> isDark = ValueNotifier<bool>(false);

  void updateValue(ThemeData themes) {
    theme.value = themes;
  }

  void toggleTheme() {
    if (theme.value.brightness == Brightness.light) {
      updateValue(darkTheme);
      isDark.value = true;
    } 
    else {
      updateValue(lightTheme);
      isDark.value = false;
    }
  }

  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Cabin',
    textTheme: CTextTheme.lightTextTheme,
    inputDecorationTheme: CInputDecorationTheme.lightInputDecorationTheme,
    textSelectionTheme: CTextSelectionThemes.lightTextSelectionThemeData,

    colorScheme: CColorThemes.lightScheme,
    appBarTheme: lightAppBar,
    bottomNavigationBarTheme: lightBottomNavBar,
    cardTheme: CardTheme(color: CColorThemes.lightScheme.primary),
  );



  ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Cabin',
    textTheme: CTextTheme.darkTextTheme,
    inputDecorationTheme: CInputDecorationTheme.darkInputDecorationTheme,
    textSelectionTheme: CTextSelectionThemes.darkTextSelectionThemeData,

    colorScheme: CColorThemes.darkScheme,
    appBarTheme: darkAppBar,
    bottomNavigationBarTheme: darkBottomNavBar,
    cardTheme: CardTheme(color: CColorThemes.darkScheme.primary),
  );
}