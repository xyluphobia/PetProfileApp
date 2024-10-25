import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:pet_profile_app/account_details.dart';
import 'package:pet_profile_app/contact_us_view.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/utils/common_util.dart';
import 'package:pet_profile_app/utils/maps_util.dart';
import 'package:pet_profile_app/utils/network_util.dart';
import 'package:provider/provider.dart';

import 'common/location_list_tile.dart';
import 'pet_details.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late Account account;
  bool unsavedChanges = false;
  bool savedConfirmVisible = false;
  bool deletedNotSave = false;

  final TextEditingController accNameController = TextEditingController();
  final TextEditingController accPrefVetAddress = TextEditingController();
  final TextEditingController accPrefVetNum = TextEditingController();
  final TextEditingController accEmeVetAddress = TextEditingController();
  final TextEditingController accEmeVetNum = TextEditingController();

  bool needNewPrefVetImage = false;
  bool needNewEmeVetImage = false;

  bool searchingForPreferredLocation = false;
  bool searchingForEmergencyLocation = false;
  List<AutocompletePrediction> preferredPlacePredictions = [];
  List<AutocompletePrediction> emergencyPlacePredictions = [];

  Future<void> saveAccountData() async {
    if (account.preferredVet.address?.isEmpty ?? true) account.preferredVet.address = null;
    if (account.preferredVet.phoneNumber?.isEmpty ?? true) account.preferredVet.phoneNumber = null;
    if (account.emergencyVet.address?.isEmpty ?? true) account.emergencyVet.address = null;
    if (account.emergencyVet.phoneNumber?.isEmpty ?? true) account.emergencyVet.phoneNumber = null;

    if (needNewPrefVetImage) {
      // set preferred vet image
      account.preferredVet.locationImagePath = await mapStaticImageGetter(account.preferredVet.address); 
      needNewPrefVetImage = false;
    }
    if (!mounted) return;
    if (needNewEmeVetImage) {
      // set emergency vet image
      account.emergencyVet.locationImagePath = await mapStaticImageGetter(account.emergencyVet.address);
      needNewEmeVetImage = false;
    }

    if (!mounted) return;
    await context.read<FileController>().writeAccountDetails(account);
    setState(() {
      unsavedChanges = false;
      deletedNotSave = false;
      savedConfirmVisible = true;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        savedConfirmVisible = false;
      });
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    account = context.watch<FileController>().accountDetails != null ? context.watch<FileController>().accountDetails! : Account();

    if (!unsavedChanges) {
      accNameController.text = account.name ?? "";
      accPrefVetAddress.text = account.preferredVet.address ?? "";
      accPrefVetNum.text = account.preferredVet.phoneNumber ?? "";
      accEmeVetAddress.text = account.emergencyVet.address ?? "";
      accEmeVetNum.text = account.emergencyVet.phoneNumber ?? "";
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ImageIcon(const Image(image: Svg('assets/petTetherIcon.svg')).image, size: 28,),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: saveAccountData, 
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 8,
                right: 16,
                left: 16,
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card( // Account Information
                    child:Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 4.0),
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
                                  setState(() {
                                    unsavedChanges = true;
                                    account.name = text;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Enter your name...",
                                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        unsavedChanges = true;
                                        account.name = "";
                                        accNameController.clear();
                                      });
                                    },
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 18,
                                    icon: Icon(
                                      Icons.clear,
                                      color: accNameController.text.isNotEmpty ? 
                                        Theme.of(context).colorScheme.onSurface :
                                        Colors.transparent,
                                    ),
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
                                
                                onChanged: (text) async {
                                  unsavedChanges = true;
                                  needNewPrefVetImage = true;
            
                                  preferredPlacePredictions = await mapPlaceAutoComplete(text);
                                  setState(() {
                                    preferredPlacePredictions;
                                  });
                                  
                                  if (text.isEmpty)
                                  {
                                    setState(() {
                                      searchingForPreferredLocation = false;
                                    });
                                  }
                                  else
                                  {
                                    setState(() {
                                      searchingForPreferredLocation = true;
                                    });
                                  }
                                },
                                onSubmitted: (value) {
                                  setState(() {
                                    searchingForPreferredLocation = false;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Enter address...",
                                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        unsavedChanges = true;
                                        needNewPrefVetImage = true;
                                        account.preferredVet.address = "";
                                        accPrefVetAddress.clear();
                                      });
                                    },
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 18,
                                    icon: Icon(
                                      Icons.clear,
                                      color: accPrefVetAddress.text.isNotEmpty ? 
                                        Theme.of(context).colorScheme.onSurface :
                                        Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Stack(
                            fit: StackFit.loose,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                        
                                        onChanged: (text) {
                                          // validate phone number then if it passes:
                                          setState(() {
                                            unsavedChanges = true;
                                            account.preferredVet.phoneNumber = text;  
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Enter phone number...",
                                          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                          isDense: true,
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                unsavedChanges = true;
                                                account.preferredVet.phoneNumber = "";
                                                accPrefVetNum.clear();
                                              });
                                            },
                                            visualDensity: VisualDensity.compact,
                                            iconSize: 18,
                                            icon: Icon(
                                              Icons.clear,
                                              color: accPrefVetNum.text.isNotEmpty ? 
                                                Theme.of(context).colorScheme.onSurface :
                                                Colors.transparent,
                                            ),
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
                                        
                                        onChanged: (text) async {
                                          unsavedChanges = true;
                                          needNewEmeVetImage = true;
            
                                          emergencyPlacePredictions = await mapPlaceAutoComplete(text);
                                          setState(() {
                                            emergencyPlacePredictions;
                                          });
                                          
                                          if (text.isEmpty)
                                          {
                                            setState(() {
                                              searchingForEmergencyLocation = false;
                                            });
                                          }
                                          else
                                          {
                                            setState(() {
                                              searchingForEmergencyLocation = true;
                                            });
                                          }
                                        },
                                        onSubmitted: (value) {
                                          setState(() {
                                            searchingForEmergencyLocation = false;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Enter address...",
                                          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                          isDense: true,
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                unsavedChanges = true;
                                                needNewEmeVetImage = true;
                                                account.emergencyVet.address = "";
                                                accEmeVetAddress.clear();
                                              });
                                            },
                                            visualDensity: VisualDensity.compact,
                                            iconSize: 18,
                                            icon: Icon(
                                              Icons.clear,
                                              color: accEmeVetAddress.text.isNotEmpty ? 
                                                Theme.of(context).colorScheme.onSurface :
                                                Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Stack(
                                    fit: StackFit.loose,
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(height: 4.0),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 2.0),
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
                                                
                                                onChanged: (text) {
                                                  // validate phone number then if it passes:
                                                  setState(() {
                                                    unsavedChanges = true;
                                                    account.emergencyVet.phoneNumber = text;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "Enter phone number...",
                                                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                                  isDense: true,
                                                  suffixIcon: IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        unsavedChanges = true;
                                                        account.emergencyVet.phoneNumber = "";
                                                        accEmeVetNum.clear();
                                                      });
                                                    },
                                                    visualDensity: VisualDensity.compact,
                                                    iconSize: 18,
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: accEmeVetNum.text.isNotEmpty ? 
                                                        Theme.of(context).colorScheme.onSurface :
                                                        Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (searchingForEmergencyLocation) Container(
                                        decoration: ShapeDecoration( 
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0)))
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: emergencyPlacePredictions.isNotEmpty ? max(emergencyPlacePredictions.length - 1, 1) : 0,
                                          itemBuilder: (context, index) => LocationListTile(
                                            indexPassed: index,
                                            listLength: emergencyPlacePredictions.length,
                                            location: emergencyPlacePredictions[index].description!,
                                            noDivider: true,
                                            press: () {
                                              setState(() {
                                                searchingForEmergencyLocation = false;
                                                account.emergencyVet.address = emergencyPlacePredictions[index].description!;
                                                accEmeVetAddress.text = account.emergencyVet.address!;
                                              });
                                              FocusManager.instance.primaryFocus?.unfocus(); // Dismisses keyboard when a tile is clicked.
                                              notification(context, 
                                                "Reminder",
                                                "Please ensure that your chosen emergency vet operates 24/7 and can provide care for your pet's species.", 
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (searchingForPreferredLocation) Container(
                                decoration: ShapeDecoration( 
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0)))
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: preferredPlacePredictions.isNotEmpty ? max(preferredPlacePredictions.length - 1, 1) : 0,
                                  itemBuilder: (context, index) => LocationListTile(
                                    indexPassed: index,
                                    listLength: preferredPlacePredictions.length,
                                    location: preferredPlacePredictions[index].description!,
                                    noDivider: true,
                                    press: () {
                                      setState(() {
                                        searchingForPreferredLocation = false;
                                        account.preferredVet.address = preferredPlacePredictions[index].description!;
                                        accPrefVetAddress.text = account.preferredVet.address!;
                                      });
                                      FocusManager.instance.primaryFocus?.unfocus(); // Dismisses keyboard when a tile is clicked.
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container( // Contact Me Button
                    margin: const EdgeInsets.only(left: 2.0, right: 2.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const ContactUsView(),
                          )
                        );
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 1, 
                      ),
                      child: Text(
                        "Contact Me",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  IntrinsicHeight( // Reset & Delete Buttons
                    child: Row(
                      children: [
                        const SizedBox(width: 2.0),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              confirmDelete(context, true);
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
                              confirmDelete(context, false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              elevation: 1,
                            ),
                            child: Text(
                              "Delete Pets",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: savedConfirmVisible ? 1 : 0,
            duration: savedConfirmVisible ? const Duration(milliseconds: 100) : const Duration(milliseconds: 1000),
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.topCenter,
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                child: Container(
                  width: 74,
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    deletedNotSave ? "Reset!" : "Saved!", 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
          
  Future<void> confirmDelete(BuildContext context, bool resetAccount) {
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        titlePadding: const EdgeInsets.only(left: 24, top: 24),
        title: Text(
          "${resetAccount ? "Reset Account" : "Delete Pets"}?", 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(decoration: TextDecoration.underline),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Text(
          "Are you sure you want to reset all ${resetAccount ? "account" : "pet data"} data? This action cannot be undone.",
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
        buttonPadding: const EdgeInsets.all(0),
        actions: [
          TextButton(
            child: Text(
              "Cancel", 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 8.0),
          TextButton(
            style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
            child: Text(
              resetAccount ? "Reset" : "Delete", 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            onPressed: () async {

              if (resetAccount) 
              {
                await context.read<FileController>().clearAccountDetailsJson();
              }
              else {
                PetDetails? petDetails = context.read<FileController>().petDetails;
                if (petDetails != null)
                {
                  for (Pet pet in petDetails.data) {
                    if (pet.image != null) FileManager().deleteFile(pet.image);
                  }
                }

                await context.read<FileController>().clearPetDetailsJson();
              }

              if (context.mounted) Navigator.of(context).pop();

              setState(() {
                deletedNotSave = true;
                savedConfirmVisible = true;
              });
              Future.delayed(const Duration(milliseconds: 1000), () {
                setState(() {
                  savedConfirmVisible = false;
                });
              });
            },
          ),
        ],
      ),
    );
  }
}