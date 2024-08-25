import 'package:flutter/material.dart';
import 'package:pet_profile_app/pet_details_view.dart';

import '../petDetails.dart';

class AddPetCard extends StatelessWidget {
  const AddPetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => PetDetailsView(pet: Pet(name: "", image: ""), petIndex: -1,)));
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 184,
              width: 154,
              color: const Color.fromARGB(255, 223, 27, 27),
            ),
          ),
        ),
      ),
    );
  }
}