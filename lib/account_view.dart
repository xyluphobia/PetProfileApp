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
                    CircleAvatar(
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
                      "Contact",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      "919 648 9503",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "mattscav@gmail.com",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
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
                      account.homeAddress != null ? account.homeAddress! : "406 Summerlin Dr Goldsboro NC 27530 United States",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      account.preferredVetAddress != null ? account.preferredVetAddress! : "812 Moonerjin St Silverboro SC 30527 Australia",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Preferred Vet",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.red),
                    ),
                    Text(
                      "name, phone #, address",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),

            FloatingActionButton(
              heroTag: "temp1",
              onPressed: () async {
                account.name = "trial";
                account.homeAddress = "406 Summerlin Dr Goldsboro";
                account.preferredVetAddress = "812 Moonerjin St Silverboro";

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