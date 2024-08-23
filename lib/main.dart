import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 63, 63, 63),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 95, 95, 95),
          ),
        bottomNavigationBar: Container(
          height: 100,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(36.0),
              topRight: Radius.circular(36.0),
            ),
            boxShadow: [
              BoxShadow(color: Color.fromARGB(255, 48, 48, 48), spreadRadius: 0, blurRadius: 20),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36.0),
              topRight: Radius.circular(36.0),
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color.fromARGB(255, 95, 95, 95),
              selectedItemColor: Colors.amber,
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
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              right: 24,
              left: 24,
            ),
            child: Column(
              children: [
                Container(
                  color: Colors.red,
                  width: 150,
                  height: 150,
                ),
                Container(
                  color: Colors.blue,
                  width: 150,
                  height: 150,
                ),
                Container(
                  color: Colors.orange,
                  width: 150,
                  height: 150,
                ),
                Container(
                  color: Colors.green,
                  width: 150,
                  height: 150,
                ),
                Container(
                  color: Colors.deepPurple,
                  width: 150,
                  height: 150,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}