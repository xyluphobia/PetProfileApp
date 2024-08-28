import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_controller.dart';
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
  int navIndex = 1;
  List<Widget> widgetList = const [
    AccountView(),
    PetsView(),
    EmergencyView(),
  ];

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

      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Icon(Icons.pets_sharp),
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: _themeManager.themeMode == ThemeMode.dark ? const Color.fromARGB(108, 33, 34, 34) : const Color.fromARGB(108, 199, 189, 177),

          actions: [Switch(value: _themeManager.themeMode == ThemeMode.dark, onChanged: (newValue) {
            _themeManager.toggleTheme(newValue);
          })],
          ),
        bottomNavigationBar: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36.0),
              topRight: Radius.circular(36.0),
            ),
            boxShadow: [
              BoxShadow(
                color: _themeManager.themeMode == ThemeMode.dark ? const Color.fromARGB(108, 33, 34, 34) : const Color.fromARGB(108, 177, 168, 158), 
                spreadRadius: 0, 
                blurRadius: 1
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36.0),
              topRight: Radius.circular(36.0),
            ),
            child: BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  navIndex = index;
                });
              },
              currentIndex: navIndex,
              showUnselectedLabels: false,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_box_rounded),
                  label: "Account",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pets_rounded),
                  label: "Pets",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emergency),
                  label: "Emergency",
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
         index: navIndex,
         children: widgetList,
        ),
      ),
    );
  }
}