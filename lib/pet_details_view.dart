import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:provider/provider.dart';
import 'package:pet_profile_app/petDetails.dart';

class PetDetailsView extends StatefulWidget {
  final int petIndex;
  const PetDetailsView({super.key, required this.petIndex});

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
  bool newPet = false;
  late Pet pet;
  late int petIndex = widget.petIndex;

  @override
  void initState() {
    if (petIndex == -1) {
      newPet = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pet = context.select((FileController controller) => controller.petDetails == null ? Empty_Pet : 
    controller.petDetails!.data.isEmpty ? Empty_Pet : 
    newPet ? Empty_Pet : controller.petDetails!.data[petIndex]);

    void addOrEditPetData() async {
      PetDetails? petDetails = context.read<FileController>().petDetails;
      if (newPet) {
        petDetails?.data.add(pet);
        petIndex = (petDetails!.data.length - 1);
        newPet = false;
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
                Navigator.pop(context);
                context.read<FileController>().clearPetDetailsJson();
              },
              child: const Text('CLEAR ALL SAVED PETS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget basicInfoCard() {
    return Card(
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 150,
              height: 150,
              color: Colors.red,
            ),
            Column(
              textBaseline: TextBaseline.alphabetic,
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
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
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
                        const Text("age" , style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        //Text('${pet.species} / ${pet.breed}'),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 70,
                              child: TextField(
                                keyboardType: TextInputType.name,
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
                                keyboardType: TextInputType.name,
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

