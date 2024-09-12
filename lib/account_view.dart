import 'package:flutter/material.dart';
import 'package:pet_profile_app/account_details.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:provider/provider.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late Account account;

  @override
  Widget build(BuildContext context) {
    account = context.watch<FileController>().accountDetails != null ? context.watch<FileController>().accountDetails! : Account();

    return Scaffold(
      body: Column(
        children: [
          const Text(
            "Account", 
            style: TextStyle(fontSize: 40)),
          Text(account.name == null ? "ph" : account.name!),
          FloatingActionButton(
            onPressed: () async {
              account.name = "trial";

              await context.read<FileController>().writeAccountDetails(account);
            }
          ),
          FloatingActionButton(
            onPressed: () {
              context.read<FileController>().clearAccountDetailsJson();
            }
          ),
        ],
      ),
    );
  }
}