import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text(
        "Account", 
        style: TextStyle(fontSize: 40)),
    );
  }
}