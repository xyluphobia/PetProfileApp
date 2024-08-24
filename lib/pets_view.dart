import 'package:flutter/material.dart';

class PetsView extends StatelessWidget {
  const PetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Pets', style:TextStyle(fontSize: 40)),
    );
  }
}