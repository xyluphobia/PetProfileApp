import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/home_view.dart';
import 'package:pet_profile_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';

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

class _MyAppState extends State<MyApp> {

  @override
  void didChangeDependencies() {
    context.read<FileController>().readPetDetails();
    context.read<FileController>().readAccountDetails();
    super.didChangeDependencies();
  }

  ThemeManager appValueNotifier = ThemeManager.instance;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appValueNotifier.theme,
      builder: (context, value, child) { 
        return MaterialApp(
          home: const HomeView(),
          theme: value,
        );
      }
    );
  }
}