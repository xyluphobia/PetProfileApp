import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/pet_details.dart';
import 'package:pet_profile_app/pet_details_view.dart';

class PetCard extends StatefulWidget {
  final int petIndex;
  const PetCard({super.key, required this.petIndex});

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  @override
  Widget build(BuildContext context) {
    Pet pet = context.select((FileController controller) => controller.petDetails == null || controller.petDetails!.data.isEmpty) ? 
    Pet() : context.select((FileController controller) => controller.petDetails!.data[widget.petIndex]);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => PetDetailsView(petIndex: widget.petIndex,),)
          );
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 184,
            color: const Color.fromARGB(255, 59, 59, 59),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 184,
                  width: 200,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: pet.image == null ? Image.asset('assets/images/petimage.jpg') : Image.file(File(pet.image!)),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(pet.name ?? 'name', style: const TextStyle(color: Colors.white),),
                      const Divider(thickness: 1, indent: 20, endIndent: 20, height: 10,),
                      Text(pet.owner ?? 'owner', style: const TextStyle(color: Colors.white),),
                      const Divider(thickness: 1, indent: 20, endIndent: 20, height: 10,),
                      Text('${pet.gender ?? 'gender'} * ${pet.gender ?? 'age'}', style: const TextStyle(color: Colors.white),),
                    ],
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}