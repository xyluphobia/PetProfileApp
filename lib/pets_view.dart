import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_profile_app/network_util.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pet_profile_app/common/add_pet_card.dart';
import 'package:pet_profile_app/common/pet_card.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/pet_details.dart';

class PetsView extends StatefulWidget {
  const PetsView({super.key});

  @override
  State<PetsView> createState() => _PetsViewState();
}

class _PetsViewState extends State<PetsView> {
  TextEditingController enterPetCodePopupInput = TextEditingController();
  bool addCardExists = false;

  Future<bool> getPetInfo(String friendCode) async {
    String filename = friendCode.toUpperCase();
    var headers = {
      'x-ms-blob-type': 'BlockBlob'
    };
    var request = http.Request('GET', Uri.parse('https://shareblobsaccount.blob.core.windows.net/petsharecontainer/$filename.json?sv=2022-11-02&ss=b&srt=o&sp=rwactfx&se=2030-01-01T12:22:30Z&st=2024-09-13T03:22:30Z&spr=https&sig=xD0CD1nZqcd7Ub4N8qitKdTDjzv30hwUd4Une4LgSnQ%3D'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      
      Pet pet = Pet.fromJson(jsonDecode(responseString));

      Future<String> base64ToImage(String byteString) async {
        Uint8List bytes = base64Decode(byteString);
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = File("$dir/${DateTime.now()}");

        await file.writeAsBytes(bytes);
        return file.path;
      }

      if (pet.image != null) {
        pet.image = await base64ToImage(pet.image!);
      } 
      if (pet.vaccinations.isNotEmpty) {
        for (int i = 0; i < pet.vaccinations.length; i++) {
          if (pet.vaccinations[i].imagePath != "") pet.vaccinations[i].imagePath = await base64ToImage(pet.vaccinations[i].imagePath);
        }
      }
      if (pet.procedures.isNotEmpty) {
        for (int i = 0; i < pet.procedures.length; i++) {
          if (pet.procedures[i].imagePath != "") pet.procedures[i].imagePath = await base64ToImage(pet.procedures[i].imagePath);
        }
      }

      if (mounted) {
        PetDetails? petDetails = context.read<FileController>().petDetails;
        petDetails?.data.add(pet);
        await context.read<FileController>().writePetDetails(petDetails!);
      } else {
        if (kDebugMode) print("Error, data not saved.");
      }
      return true;
    }
    else {
      // need error handling for invalid code
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
       child: ListView.builder(
         itemCount: context.select((FileController controller) => controller.petDetails != null ? controller.petDetails!.data.length + 2 : 2),
         padding: const EdgeInsets.only(
          top: 4,
          bottom: 8,
          right: 16,
          left: 16,
         ),
         itemBuilder: (context, index) => getPetCard(index)),
     );
  }

  Widget getPetCard(int index) {
    PetDetails? petDetailsLocal = context.read<FileController>().petDetails;
    if (petDetailsLocal != null && index < petDetailsLocal.data.length) {
      addCardExists = false;
      return PetCard(petIndex: index,);
    }
    else if (!addCardExists) {
      addCardExists = true;
      return const AddPetCard();
    }
    else {
      String? errorMessage;
      addCardExists = false;
      return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) => StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  title: const Text("Enter Pet Code"),
                  content: TextField(
                    autofocus: true,
                    autocorrect: false,
                    showCursor: false,
                    controller: enterPetCodePopupInput,
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (text) {
                      setState(() {
                        errorMessage = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "A1B2C3",
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary,),
                      errorText: errorMessage,
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    IconButton(
                      onPressed: () {Navigator.of(context).pop();}, 
                      icon: const Icon(Icons.close_rounded),
                    ),
                    TextButton(
                      child: Text("SUBMIT", style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
                      onPressed: () async {
                        if (enterPetCodePopupInput.text.length == 6)
                        {
                          if (NetworkUtil.acceptableRequestAmount())
                          {
                            if (await getPetInfo(enterPetCodePopupInput.text)) {
                              enterPetCodePopupInput.clear();
                              if (context.mounted) Navigator.of(context).pop();
                            }
                            else {
                              setState(() {
                                errorMessage = "Code Expired or Invalid";
                              });
                            }
                          }
                          else {
                            NetworkUtil.showTooManyRequests(context);
                          }
                        } 
                        else {
                          setState(() {
                            errorMessage = "Code must be 6 Characters";
                          });
                        }
                      },
                    ),
                  ],
                );
              }
            ),
          );
        }, 
        style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary)),
        child: Text("Enter Pet Code", style: Theme.of(context).textTheme.titleSmall)
      );
    }
  }
}