import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/pet_details.dart';
import 'package:uuid/uuid.dart';

class PetDetailsView extends StatefulWidget {
  final int petIndex;
  const PetDetailsView({super.key, required this.petIndex});

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
  bool newPet = false;
  bool assignPet = true;
  late Pet pet;
  late int petIndex = widget.petIndex;

  Future selectImage(ImageSource imgSource) async {
    final returnedImage = await ImagePicker().pickImage(source: imgSource, imageQuality: 70);

    if (returnedImage == null) return;

    String savedImagePath = await FileManager().saveImage(File(returnedImage.path));
    setState(() {
      pet.image = savedImagePath;
    });
    return;
  }

  void addOrEditPetData() async {
    PetDetails? petDetails = context.read<FileController>().petDetails;
    if (newPet) {
      petDetails?.data.add(pet);
      petIndex = (petDetails!.data.length - 1);
      setState(() {
        newPet = false;
      });
    }
    else {
      petDetails?.data[petIndex] = pet;
    }

    await context.read<FileController>().writePetDetails(petDetails!);
  }

  @override
  void initState() {
    if (petIndex == -1) {
      newPet = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (assignPet) {
      pet = context.select((FileController controller) => controller.petDetails == null || controller.petDetails!.data.isEmpty) || newPet ? 
      Pet() : context.select((FileController controller) => controller.petDetails!.data[petIndex]);

      assignPet = false;
    }

    Future<String> sharePetInfo() async {
      var uuid = const Uuid();
      String filename = uuid.v4();
      filename = filename.replaceRange(6, filename.length, '');
      filename = filename.toUpperCase(); // Filename results in a random 6 character long code of numbers and letters. All letters are uppercase. 

      var headers = {
        'Content-Type': 'application/json',
        'x-ms-blob-type': 'BlockBlob'
      };
      var request = http.Request('PUT', Uri.parse('https://shareblobsaccount.blob.core.windows.net/petsharecontainer/$filename.json?sv=2022-11-02&ss=bf&srt=o&sp=wactfx&se=2025-10-01T08:19:27Z&st=2024-09-13T00:19:27Z&spr=https&sig=sF2pNHIdjPHa17nStOyabcxYwxTwnRGdxuQ9AC9XL2w%3D'));
      
      if (pet.image != null) {
        Pet tempPet = pet;
        File _imageFile = File(tempPet.image!);
        Uint8List _bytes = await _imageFile.readAsBytes();
        tempPet.image = base64Encode(_bytes);

        request.body = jsonEncode(tempPet);
      } else {
        request.body = json.encode(pet);
      }
      
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200)
      {
        //print(await response.stream.bytesToString());
        return filename;
      } 
      else {
        //print(response.reasonPhrase);
        return "Error";
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Icon(Icons.pets_sharp),
        actions: [
          IconButton(
            onPressed: addOrEditPetData, 
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      floatingActionButton: !newPet ? FloatingActionButton(
        heroTag: "sharePetInfoBtn",
        onPressed: () async {
          String petCode = await sharePetInfo();
          if (context.mounted) showPetCode(context, petCode);
        },
        child: const Icon(Icons.ios_share_rounded),
      ) : null,
      body: Container(
        margin: const EdgeInsets.only(
          top: 16,
          bottom: 8,
          left: 24,
          right: 24,
        ),
        child: Column(
          children: [
            basicInfoCard(),

            GestureDetector(
              onTap: () {
                context.read<FileController>().clearPetDetailsJson();
                Navigator.pop(context);
              },
              child: const Text('CLEAR ALL SAVED PETS'),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showPetCode(BuildContext context, String petCode) {
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        titlePadding: const EdgeInsets.only(left: 24, top: 24, bottom: 12),
        title: const Text("Pet Code", style: TextStyle(decoration: TextDecoration.underline),),
        contentPadding: const EdgeInsets.all(20),
        content: Text(
          petCode,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            letterSpacing: 12,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
        buttonPadding: const EdgeInsets.all(0),
        actions: [
          TextButton(
            child: Text("CLOSE", style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future displayBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context, 
      builder: (context) => SizedBox(
        height: 200,
        child: Column(
          children: [
            SizedBox(
              height: 99,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  selectImage(ImageSource.gallery).then((_) {
                    addOrEditPetData();
                    if (context.mounted) Navigator.pop(context);
                  });
                }, 
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.photo, color: Theme.of(context).colorScheme.onPrimary,),
                    ),
                    Text("Pick Photo", style: Theme.of(context).textTheme.headlineMedium,),
                  ],
                )
              ),
            ),
            const Divider(
              thickness: 2,
              indent: 18,
              endIndent: 18,
              height: 2,
            ),
            SizedBox(
              height: 99,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  selectImage(ImageSource.camera).then((_) {
                    addOrEditPetData();
                    if (context.mounted) Navigator.pop(context);
                  });
                }, 
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                    ),
                  ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.camera_alt_outlined, color: Theme.of(context).colorScheme.onPrimary,),
                    ),
                    Text("Take Photo", style: Theme.of(context).textTheme.headlineMedium,),
                  ],
                )
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget basicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 270,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      displayBottomSheet(context);
                    },
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: pet.image != null ? FileImage(File(pet.image!)) : const AssetImage('assets/images/petimage.jpg'),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.start,
                              autocorrect: false,
                              maxLines: 1,
        
                              onChanged: (text) {
                                pet.age = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.age,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("age", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 140,
                            child: TextField(
                              keyboardType: TextInputType.none,
                              textAlign: TextAlign.start,
                              autocorrect: false,
                              maxLines: 1,
                              showCursor: false,
        
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: pet.birthday == null ? DateTime.now() : DateFormat('dd/MM/yyyy').tryParse(pet.birthday!),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                ).then((date) {
                                  if (date != null) {
                                    setState(() {
                                      pet.birthday = DateFormat('dd/MM/yyyy').format(date);
                                    });
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                hintText: pet.birthday,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("birthday", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.name,
                              textAlign: TextAlign.end,
                              autocorrect: false,
                              maxLines: 1,
        
                              onChanged: (text) {
                                pet.name = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.name,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("name", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.name,
                              textAlign: TextAlign.end,
                              autocorrect: false,
                              maxLines: 1,
        
                              onChanged: (text) {
                                pet.owner = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.owner,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("owner", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.end,
                              autocorrect: false,
                              maxLines: 1,
        
                              onChanged: (text) {
                                pet.gender = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.gender,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("gender" , style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 30,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.end,
                                  autocorrect: false,
                                  maxLines: 1,
        
                                  onChanged: (text) {
                                    pet.species = text;
                                  },
                                  decoration: InputDecoration(
                                    hintText: pet.species,
                                    isDense: true,
                                  ),
                                ),
                              ),
        
                              const Text("/"),
        
                              SizedBox(
                                height: 30,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.end,
                                  autocorrect: false,
                                  maxLines: 1,
        
                                  onChanged: (text) {
                                    pet.breed = text;
                                  },
                                  decoration: InputDecoration(
                                    hintText: pet.breed,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text("species / breed" , style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget developmentInputFields() {
    return Column(
      children: [
        TextField(
          onChanged: (text) {
            pet.name = text;
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: newPet ? "Pet Name" : pet.name,
          ),
        ),

        TextField(
          onChanged: (text) {
            pet.owner = text;
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: newPet ? "Owner Name" : pet.owner,
          ),
        ),

        TextField(
          onChanged: (text) {
            pet.age = text;
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: newPet ? "Pet Age" : pet.age,
          ),
        ),

        TextField(
          onChanged: (text) {
            pet.species = text;
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: newPet ? "Pet Species" : pet.species,
          ),
        ),

        TextField(
          onChanged: (text) {
            pet.breed = text;
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: newPet ? "Pet Breed" : pet.breed,
          ),
        ),
      ],
    );
  }
}

