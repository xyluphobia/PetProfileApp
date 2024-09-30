import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:pet_profile_app/theme/theme_manager.dart';

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

  ThemeManager appValueNotifier = ThemeManager.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ImageIcon(const Image(image: Svg('assets/petTetherIcon.svg')).image, size: 28,),
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: navIndex == 1 ? IconButton(
          onPressed: () {
            
          }, 
          icon: const Icon(Icons.search)
        ) : null,
        actions: [
          if (navIndex == 1) ValueListenableBuilder(
            valueListenable: appValueNotifier.isDark,
            builder: (context, value, child) { 
              return Switch(
                trackOutlineWidth: const WidgetStatePropertyAll(1),
                activeTrackColor: Theme.of(context).colorScheme.surface,
                activeColor: Theme.of(context).colorScheme.onSurface,
              
                value: appValueNotifier.isDark.value, 
                onChanged: (newValue) {
                  appValueNotifier.toggleTheme();
                },
              );
            }
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
              color: appValueNotifier.isDark.value ? const Color.fromARGB(108, 34, 33, 33) : const Color.fromARGB(108, 177, 168, 158), 
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
                icon: Icon(Icons.settings),
                label: "Account",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pets_rounded),
                label: "Pets",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emergency_rounded),
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