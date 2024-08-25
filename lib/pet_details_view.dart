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
      pet = Pet(name: "", image: "");
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    void addOrEditPetData() async {
      pet.name = "new test pet";

      PetDetails? petDetails = context.read<FileController>().petDetails;
      if (newPet) {
        petDetails?.data.add(pet);
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
      body: Column(
        children: [
          Text('Details For ${newPet ? "a New Pet!" : pet.name}'),

        

          GestureDetector(
            onTap: () {
              addOrEditPetData();
            },
            child: const Text('SAVE PET DATA')
          ),

          GestureDetector(
            onTap: () {
              context.read<FileController>().clearPetDetailsJson();
            },
            child: const Text('CLEAR ALL SAVED PETS'),
          ),
        ],
      ),
    );
  }
}