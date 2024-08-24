import 'package:flutter/material.dart';
import 'package:pet_profile_app/common/pet_card.dart';

class PetsView extends StatelessWidget {
  const PetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            PetCard(),
            PetCard(),
            PetCard(),
            PetCard(),
            PetCard(),
            PetCard(),
            PetCard(),
            PetCard(),
            PetCard(),
            PetCard(),
          ],
        ),
      ),
    );
  }
}