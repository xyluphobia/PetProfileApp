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

  @override
  void initState() {
    if (widget.petIndex == -1) {
      newPet = true;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!newPet) {
      pet = context.read<FileController>().petDetails!.data[widget.petIndex];
    } else {
      pet = Empty_Pet;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    void addOrEditPetData() async {
      PetDetails? petDetails = context.read<FileController>().petDetails;
      if (newPet) {
        petDetails?.data.add(pet);
        newPet = false;
      }
      else {
        petDetails?.data[widget.petIndex] = pet;
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
            // Display circular image of the pet. Model this page after a contacts page.
            TextField(
              onChanged: (text) {
                pet.name = text;
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: newPet ? "Pet Name" : pet.name,
              ),
            ),
        
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
}