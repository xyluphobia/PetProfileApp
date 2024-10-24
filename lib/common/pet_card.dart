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
    if (context.read<FileController>().petDetails != null)
    {
      if (widget.petIndex <= context.read<FileController>().petDetails!.data.length)
      {
        
      }
    }

    Pet pet = context.select((FileController controller) => controller.petDetails == null || 
    controller.petDetails!.data.isEmpty || 
    widget.petIndex >= controller.petDetails!.data.length) ? 
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
          child: SizedBox(
            height: 184,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 184,
                  width: 200,
                  child: pet.image != null ? FittedBox(
                    fit: BoxFit.fill,
                    //child: pet.image == null ? Image.asset('assets/images/petimage.jpg') : Image.file(File(pet.image!)),
                    child:  Image.file(File(pet.image!))
                  ) :
                  const Icon(
                    Icons.pets,
                    size: 100,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: pet.notOwnedByAccount ? BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ), 
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12), 
                        bottomRight: Radius.circular(12)
                      ),
                    ) : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(pet.name ?? 'name', style: Theme.of(context).textTheme.headlineMedium,),
                        const Divider(thickness: 1, indent: 20, endIndent: 20, height: 10,),
                        Text(
                          pet.owner ?? 'owner', 
                          style: pet.notOwnedByAccount ? 
                            Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary) :
                            Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Divider(thickness: 1, indent: 20, endIndent: 20, height: 10,),
                        Text('${pet.gender ?? 'gender'} * ${pet.age ?? 'age'}', style: Theme.of(context).textTheme.bodyLarge,),
                      ],
                    ),
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