import 'package:flutter/material.dart';



ColorScheme lightScheme = const ColorScheme(
    brightness: Brightness.light,
    surface: Color(0xFFede4d4),
    onSurface: Color(0xFFf68e5f),
    primary: Color(0xFFf3ede2), 
    onPrimary: Color(0xFF100000), 
    secondary: Color(0xFF5e6572), 
    onSecondary: Color(0xFFf68e5f),
    error: Color(0xFFae3e0a), 
    onError: Color(0xFFf3ede2), 
);

ColorScheme darkScheme = const ColorScheme(
  brightness: Brightness.dark,
  surface: Color.fromARGB(255, 34, 34, 34), 
  onSurface: Color(0xFF66b2b2),
  primary: Color.fromARGB(255, 51, 51, 51), 
  onPrimary: Colors.white, 
  secondary: Color(0xFF5e6572), 
  onSecondary: Color(0xFFf68e5f),
  error: Color(0xFFae3e0a), 
  onError: Color(0xFFf3ede2), 
);