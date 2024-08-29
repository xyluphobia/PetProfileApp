import 'package:flutter/material.dart';
import 'package:pet_profile_app/pet_details_view.dart';

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
              builder: (context) => const PetDetailsView(petIndex: -1,)));
        },
        child: const Card(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 184,
            width: 154,
          ),
        ),
      ),
    );
  }
}