import 'package:flutter/material.dart';
import 'package:pet_profile_app/petDetails.dart';
import 'package:pet_profile_app/file_manager.dart';

class PetDetailsView extends StatefulWidget {
  final Pet pet;
  final int petIndex;
  const PetDetailsView({super.key, required this.pet, required this.petIndex});

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
  bool newPet = false;

  @override
  void initState() {
    if (widget.petIndex == -1) {
      newPet = true;
    }
    super.initState();
  }

  void addOrEditPetData() async {
    widget.pet.name = "new test pet";

    PetDetails petDetails = petDetailsFromJson(await FileManager().getJsonString());
    if (newPet) {
      petDetails.data.add(widget.pet);
    }
    else {
      petDetails.data[widget.petIndex] = widget.pet;
    }

    await FileManager().writeJsonFile(petDetailsToJson(petDetails));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 34, 34, 34),
          iconTheme: const IconThemeData(
            color: Color(0xFF66b2b2),
          ),
          centerTitle: true,
          title: const Icon(Icons.pets_sharp, color: Color(0xFF66b2b2),),
          ),
      body: GestureDetector(
        onTap: () {
          addOrEditPetData();
        },
        child: Text('details for ${newPet ? "new pet" : widget.pet.name}'),
        ),
    );
  }
}