import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
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
  bool unsavedChanges = false;

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
              child:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Information",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Name",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    SizedBox( // Account name
                      height: 24,
                      child: TextField(
                        keyboardType: TextInputType.name,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyLarge,
                        autocorrect: false,
                        maxLines: 1,
                        enabled: true,
                        
                        onChanged: (text) {
                          unsavedChanges = true;
                          account.name = text;
                        },
                        decoration: InputDecoration(
                          hintText: account.name ?? "Enter your name...",
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
                          isDense: true,
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Preferred Vet",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    SizedBox( // preferred vet address
                      height: 24,
                      child: TextField(
                        keyboardType: TextInputType.streetAddress,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyLarge,
                        autocorrect: false,
                        maxLines: 1,
                        enabled: true,
                        
                        onChanged: (text) {
                          // validate address then if it passes:
                          // format address
                          unsavedChanges = true;
                          account.preferredVet.address = text;
                        },
                        decoration: InputDecoration(
                          hintText: account.preferredVet.address ?? "Enter address...",
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
                          isDense: true,
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                    SizedBox( // Preferred vet phone number
                      height: 24,
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyLarge,
                        autocorrect: false,
                        maxLines: 1,
                        enabled: true,
                        inputFormatters: [
                          MaskedInputFormatter('(###) ###-####')
                        ],
                        
                        onChanged: (text) {
                          // validate phone number then if it passes:
                    
                          unsavedChanges = true;
                          account.preferredVet.phoneNumber = text;
                        },
                        decoration: InputDecoration(
                          hintText: account.preferredVet.phoneNumber ?? "Enter phone number...",
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
                          isDense: true,
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Emergency Vet",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    SizedBox( // Emergency vet address
                      height: 24,
                      child: TextField(
                        keyboardType: TextInputType.streetAddress,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyLarge,
                        autocorrect: false,
                        maxLines: 1,
                        enabled: true,
                        
                        onChanged: (text) {
                          // validate address then if it passes:
                          // format address
                          unsavedChanges = true;
                          account.emergencyVet.address = text;
                        },
                        decoration: InputDecoration(
                          hintText: account.emergencyVet.address ?? "Enter address...",
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
                          isDense: true,
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                    SizedBox( // Emergency vet phone number
                      height: 24,
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyLarge,
                        autocorrect: false,
                        maxLines: 1,
                        enabled: true,
                        inputFormatters: [
                          MaskedInputFormatter('(###) ###-####')
                        ],
                        
                        onChanged: (text) {
                          // validate phone number then if it passes:
                    
                          unsavedChanges = true;
                          account.emergencyVet.phoneNumber = text;
                        },
                        decoration: InputDecoration(
                          hintText: account.emergencyVet.phoneNumber ?? "Enter phone number...",
                          hintStyle: Theme.of(context).textTheme.bodyLarge,
                          isDense: true,
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            FloatingActionButton(
              heroTag: "temp1",
              onPressed: () async {
                await context.read<FileController>().writeAccountDetails(account);
              },
              child: const Text("Save"),
            ),
            FloatingActionButton(
              heroTag: "temp2",
              onPressed: () async {
                print(account.toJson());
              },
              child: const Text("Print Account"),
            ),
            FloatingActionButton(
              heroTag: "temp3",
              onPressed: () {
                context.read<FileController>().clearAccountDetailsJson();
              },
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}