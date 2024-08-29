import 'package:flutter/material.dart';
import 'package:pet_profile_app/account_view.dart';
import 'package:pet_profile_app/emergency_view.dart';
import 'package:pet_profile_app/pets_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int navIndex = 1;
  List<Widget> widgetList = const [
    AccountView(),
    PetsView(),
    EmergencyView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Icon(Icons.pets_sharp),
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: _themeManager.themeMode == ThemeMode.dark ? const Color.fromARGB(108, 33, 34, 34) : const Color.fromARGB(108, 199, 189, 177),
          actions: [
            Switch(
              trackOutlineWidth: const WidgetStatePropertyAll(1),
              activeTrackColor: const Color.fromARGB(255, 34, 34, 34),
              activeColor: const Color(0xFF66b2b2),

              value: _themeManager.themeMode == ThemeMode.dark, 
              onChanged: (newValue) {
                _themeManager.toggleTheme(newValue);
              },
            ),
          ],
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
      );
  }
}