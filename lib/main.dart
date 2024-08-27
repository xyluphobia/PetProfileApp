import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_controller.dart';
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

class _MyAppState extends State<MyApp> {
  int navIndex = 1;
  List<Widget> widgetList = const [
    AccountView(),
    PetsView(),
    EmergencyView(),
  ];

  @override
  void didChangeDependencies() {
    context.read<FileController>().readPetDetails();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Cabin',
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: 1.4, 
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 34, 34, 34),
          centerTitle: true,
          title: const Icon(Icons.pets_sharp, color: Color(0xFF66b2b2),),
          ),
        bottomNavigationBar: Container(
          height: 100,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(36.0),
              topRight: Radius.circular(36.0),
            ),
            boxShadow: [
              BoxShadow(color: Color.fromARGB(255, 53, 53, 53), spreadRadius: 0, blurRadius: 5),
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
              backgroundColor: const Color.fromARGB(255, 34, 34, 34),
              selectedItemColor: const Color(0xFF66b2b2),
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