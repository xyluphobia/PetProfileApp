import 'package:flutter/material.dart';
import 'package:pet_profile_app/petDetails.dart';
import 'package:pet_profile_app/pet_details_view.dart';

class PetCard extends StatefulWidget {
  final Datum petDetails;
  const PetCard({super.key, required this.petDetails});

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
              builder: (context) => PetDetailsView(petDetails: widget.petDetails),));
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
                  Expanded(
                    child: Image.asset('assets/img.jpg')
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(widget.petDetails.petName, style: const TextStyle(color: Colors.white),),
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