import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
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

  void getPetInfo(String friendCode) async {
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
      if (pet.image != null) {
        Uint8List _bytes = base64Decode(pet.image!);
        String dir = (await getApplicationDocumentsDirectory()).path;
        File file = File("$dir/${DateTime.now()}");

        await file.writeAsBytes(_bytes);
        pet.image = file.path;
      }

      if (mounted) {
        PetDetails? petDetails = context.read<FileController>().petDetails;
        petDetails?.data.add(pet);
        await context.read<FileController>().writePetDetails(petDetails!);
      } else {
        if (kDebugMode) print("Error, data not saved.");
      }
    }
    else {
      // need error handling for invalid code
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
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
      addCardExists = false;
      return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) => AlertDialog(
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
                decoration: InputDecoration(
                  hintText: "A1B2C3",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary,),
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
                  onPressed: () {
                    if (enterPetCodePopupInput.text.length == 6)
                    {
                      getPetInfo(enterPetCodePopupInput.text);
                      Navigator.of(context).pop();
                    }
                    // Show error that code is not valid
                  },
                ),
              ],
            ),
          );
        }, 
        style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary)),
        child: Text("Enter Pet Code", style: Theme.of(context).textTheme.titleSmall)
      );
    }
  }
}