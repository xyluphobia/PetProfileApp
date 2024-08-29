import 'package:flutter/material.dart';
import 'package:pet_profile_app/theme/input_decoration_theme.dart';
import 'package:pet_profile_app/theme/text_theme.dart';


ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Cabin',
  textTheme: CTextTheme.lightTextTheme,
  inputDecorationTheme: CInputDecorationTheme.lightInputDecorationTheme,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    surface: Color(0xFFede4d4),
    onSurface: Color(0xFFf68e5f),
    primary: Color(0xFFf3ede2), 
    onPrimary: Color(0xFF100000), 
    secondary: Color(0xFF5e6572), 
    onSecondary: Color(0xFFf68e5f),
    error: Color(0xFFae3e0a), 
    onError: Color(0xFFf3ede2), 
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFf3ede2),
    iconTheme: IconThemeData(
      color: Color(0xFFf68e5f),
    )
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFf3ede2),
    selectedItemColor: Color(0xFFf68e5f),
    unselectedItemColor: Color(0xFF5e6572),
  ),
  cardTheme: const CardTheme(color: Color(0xFFf3ede2)),
);



ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Cabin',
  textTheme: CTextTheme.darkTextTheme,
  inputDecorationTheme: CInputDecorationTheme.darkInputDecorationTheme,

  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    surface: Color.fromARGB(255, 34, 34, 34), 
    onSurface: Color(0xFF66b2b2),
    primary: Color.fromARGB(255, 51, 51, 51), 
    onPrimary: Color(0xFF100000), 
    secondary: Color(0xFF5e6572), 
    onSecondary: Color(0xFFf68e5f),
    error: Color(0xFFae3e0a), 
    onError: Color(0xFFf3ede2), 
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 51, 51, 51),
    iconTheme: IconThemeData(
      color: Color(0xFF66b2b2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 51, 51, 51),
    selectedItemColor: Color(0xFF66b2b2),
    unselectedItemColor: Color(0xFF5e6572),
  ),
  cardTheme: const CardTheme(color: Color.fromARGB(255, 51, 51, 51)),
);