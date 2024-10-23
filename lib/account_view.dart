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

    return Center(
      child: Container(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 8,
          right: 16,
          left: 16,
         ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.amber,
                    ),
                    Text(
                      account.name != null ? account.name! : "First Last",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              )
            ),
            Card(
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Locations",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      "Preferred Vet",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      account.preferredVet.address != null ? account.preferredVet.address! : "812 Example St Example SC 30527 Australia",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "Emergency Vet",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      account.emergencyVet.address != null ? account.emergencyVet.address! : "812 Example St Example SC 30527 Australia",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            FloatingActionButton(
              heroTag: "temp1",
              onPressed: () async {
                account.name = "test name";
                account.preferredVet.address = "812 Example St Example";

                await context.read<FileController>().writeAccountDetails(account);
              },
              child: const Text("Test Button 1"),
            ),
            FloatingActionButton(
              heroTag: "temp2",
              onPressed: () {
                context.read<FileController>().clearAccountDetailsJson();
              },
              child: const Text("Reset Button"),
            ),
          ],
        ),
      ),
    );
  }
}