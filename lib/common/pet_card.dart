import 'package:flutter/material.dart';
import 'package:pet_profile_app/petDetails.dart';
import 'package:pet_profile_app/pet_details_view.dart';

class PetCard extends StatefulWidget {
  final Pet pet;
  final int petIndex;
  const PetCard({super.key, required this.pet, required this.petIndex});

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 184,
              width: 154,
              color: const Color.fromARGB(255, 59, 59, 59),
              child: Column(
                children: [
                  const Expanded(
                    child: Icon(Icons.pets_sharp),
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(widget.pet.name, style: const TextStyle(color: Colors.white),),
                          const Text("gender * age", style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      Container(
                        height: 15,
                        width: 15,
                        color: Colors.red,
                      )
                    ],
                  ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}