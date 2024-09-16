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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.amber,
                ),
                Text(account.name != null ? account.name! : "First Last"),
              ],
            )
          ),
          const SizedBox(
            child:Column(
              children: [
                Text("Contact"),
                Text("919 648 95003"),
                Text("mattscav@gmail.com"),
              ],
            ),
          ),
          const SizedBox(
            child:Column(
              children: [
                Text("Locations"),
                Text("406 Summerlin Dr Goldsboro NC 27530 United States"),
                Text("812 Moonerjin St Silverboro SC 30527 Australia"),
              ],
            ),
          ),
          FloatingActionButton(
            heroTag: "temp1",
            onPressed: () async {
              account.name = "trial";

              await context.read<FileController>().writeAccountDetails(account);
            }
          ),
          FloatingActionButton(
            heroTag: "temp2",
            onPressed: () {
              context.read<FileController>().clearAccountDetailsJson();
            }
          ),
        ],
      ),
    );
  }
}