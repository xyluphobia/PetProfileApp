import 'package:flutter/material.dart';
import 'package:pet_profile_app/petDetails.dart';

class PetDetailsView extends StatefulWidget {
  final bool newPet;
  final Pet? pet;
  final int? petIndex;
  const PetDetailsView({super.key, required this.newPet, this.pet, this.petIndex});

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
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
          widget.pet!.name = "Test";
        },
        child: Text('details for ${widget.newPet ? "new pet" : widget.pet!.name}'),
        ),
    );
  }
}