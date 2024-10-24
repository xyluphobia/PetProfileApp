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

  final TextEditingController accNameController = TextEditingController();
  final TextEditingController accPrefVetAddress = TextEditingController();
  final TextEditingController accPrefVetNum = TextEditingController();
  final TextEditingController accEmeVetAddress = TextEditingController();
  final TextEditingController accEmeVetNum = TextEditingController();

  @override
  Widget build(BuildContext context) {
    account = context.watch<FileController>().accountDetails != null ? context.watch<FileController>().accountDetails! : Account();

    account.name != null ? accNameController.text = account.name! : accNameController.text = "";
    account.preferredVet.address != null ? accPrefVetAddress.text = account.preferredVet.address! : accPrefVetAddress.text = "";
    account.preferredVet.phoneNumber != null ? accPrefVetNum.text = account.preferredVet.phoneNumber! : accPrefVetNum.text = "";
    account.emergencyVet.address != null ? accEmeVetAddress.text = account.emergencyVet.address! : accEmeVetAddress.text = "";
    account.emergencyVet.phoneNumber != null ? accEmeVetNum.text = account.emergencyVet.phoneNumber! : accEmeVetNum.text = "";

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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SizedBox( // Account name
                        height: 24,
                        child: TextField(
                          keyboardType: TextInputType.name,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge,
                          autocorrect: false,
                          maxLines: 1,
                          controller: accNameController,
                          enabled: true,
                          
                          onChanged: (text) {
                            unsavedChanges = true;
                            account.name = text;
                          },
                          decoration: InputDecoration(
                            hintText: "Enter your name...",
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            isDense: true,
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                            ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SizedBox( // preferred vet address
                        height: 24,
                        child: TextField(
                          keyboardType: TextInputType.streetAddress,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge,
                          autocorrect: false,
                          maxLines: 1,
                          controller: accPrefVetAddress,
                          enabled: true,
                          
                          onChanged: (text) {
                            // validate address then if it passes:
                            // format address
                            unsavedChanges = true;
                            account.preferredVet.address = text;
                          },
                          decoration: InputDecoration(
                            hintText: "Enter address...",
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            isDense: true,
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SizedBox( // Preferred vet phone number
                        height: 24,
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge,
                          autocorrect: false,
                          maxLines: 1,
                          controller: accPrefVetNum,
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
                            hintText: "Enter phone number...",
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            isDense: true,
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                            ),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SizedBox( // Emergency vet address
                        height: 24,
                        child: TextField(
                          keyboardType: TextInputType.streetAddress,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge,
                          autocorrect: false,
                          maxLines: 1,
                          controller: accEmeVetAddress,
                          enabled: true,
                          
                          onChanged: (text) {
                            // validate address then if it passes:
                            // format address
                            unsavedChanges = true;
                            account.emergencyVet.address = text;
                          },
                          decoration: InputDecoration(
                            hintText: "Enter address...",
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            isDense: true,
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SizedBox( // Emergency vet phone number
                        height: 24,
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyLarge,
                          autocorrect: false,
                          maxLines: 1,
                          controller: accEmeVetNum,
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
                            hintText: "Enter phone number...",
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            isDense: true,
                            disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            IntrinsicHeight(
              child: Row(
                children: [
                  const SizedBox(width: 1.0),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<FileController>().clearAccountDetailsJson();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 1,
                      ),
                      child: Text(
                        "Reset Account",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<FileController>().clearPetDetailsJson();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 1,
                      ),
                      child: Text(
                        "Reset Pets",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}