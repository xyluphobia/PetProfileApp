import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/pet_details.dart';

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
    final returnedImage = await ImagePicker().pickImage(source: imgSource);

    if (returnedImage == null) return;

    String savedImagePath = await FileManager().saveImage(File(returnedImage.path));
    setState(() {
      assignPet = false;
      pet.image = savedImagePath;
    });
    return;
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

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 34, 34, 34),
          iconTheme: const IconThemeData(
            color: Color(0xFF66b2b2),
          ),
          centerTitle: true,
          title: const Icon(Icons.pets_sharp, color: Color(0xFF66b2b2),),
          ),
      body: Container(
        margin: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: 24,
          right: 24,
        ),
        child: Column(
          children: [
            Text('Details For ${newPet ? "a New Pet!" : pet.name}'),

            //developmentInputFields(),
            basicInfoCard(),

            GestureDetector(
              onTap: () {
                addOrEditPetData();
              },
              child: const Text('SAVE PET DATA')
            ),

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

  Future displayBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context, 
      builder: (context) => Container(
        height: 200,
        child: Column(
          children: [
            SizedBox(
              height: 99,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  selectImage(ImageSource.gallery).then((_) {
                    if (context.mounted) Navigator.pop(context);
                  });
                }, 
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.photo),
                    ),
                    Text("Pick Photo", textScaler: TextScaler.linear(1.5),),
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
                    if (context.mounted) Navigator.pop(context);
                  });
                }, 
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                    ),
                  ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.camera_alt_outlined),
                    ),
                    Text("Take Photo", textScaler: TextScaler.linear(1.5),),
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
          height: 250,
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
                            height: 20,
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
                                hintText: pet.age
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
                            height: 20,
                            width: 100,
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
                            height: 20,
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
                                hintText: pet.name
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
                            height: 20,
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
                                hintText: pet.owner
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
                            height: 20,
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
                                hintText: pet.gender
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
                                height: 20,
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
                                    hintText: pet.species
                                  ),
                                ),
                              ),
        
                              const Text("/"),
        
                              SizedBox(
                                height: 20,
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
                                    hintText: pet.breed
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

