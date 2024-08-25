import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_profile_app/common/add_pet_card.dart';
import 'package:pet_profile_app/common/pet_card.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/petDetails.dart';

class PetsView extends StatefulWidget {
  const PetsView({super.key});

  @override
  State<PetsView> createState() => _PetsViewState();
}

class _PetsViewState extends State<PetsView> {
  late PetDetails petDetails;
  bool isDataLoaded = true;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return !isDataLoaded ? const Center(child: CircularProgressIndicator(),) :
           errorMsg.isNotEmpty ? Center(child: Text(errorMsg)) : 
     Center(
       child: ListView.builder(
         itemCount: context.select((FileController controller) => controller.petDetails != null ? controller.petDetails!.data.length + 1 : 1),
         padding: const EdgeInsets.only(
          top: 4,
          bottom: 8,
          right: 16,
          left: 16,
         ),
         itemBuilder: (context, index) => getPetCard(index)),
     );
  }

  Widget getPetCard(int index) {
    PetDetails? petDetailsLocal = context.read<FileController>().petDetails;
    if (petDetailsLocal != null && index < petDetailsLocal.data.length) {
      return PetCard(pet: petDetailsLocal.data[index], petIndex: index,);
    }
    else {
      return const AddPetCard();
    }
  }
}