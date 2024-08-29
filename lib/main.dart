import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/home_view.dart';
import 'package:pet_profile_app/theme/theme_constants.dart';
import 'package:pet_profile_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:pet_profile_app/account_view.dart';
import 'package:pet_profile_app/emergency_view.dart';
import 'package:pet_profile_app/pets_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FileController())], 
      child: const MyApp())
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

ThemeManager _themeManager = ThemeManager();

class _MyAppState extends State<MyApp> {

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  } 

  themeListener() {
    if (mounted) {
      setState(() {
      });
    }
  }

  @override
  void didChangeDependencies() {
    context.read<FileController>().readPetDetails();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,

      home: HomeView()
    );
  }
}