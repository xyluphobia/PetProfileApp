import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pet_profile_app/common/add_pet_card.dart';
import 'package:pet_profile_app/common/pet_card.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/petDetails.dart';
import 'package:provider/provider.dart';

class PetsView extends StatefulWidget {
  const PetsView({super.key});

  @override
  State<PetsView> createState() => _PetsViewState();
}

class _PetsViewState extends State<PetsView> {
  late PetDetails petDetails;
  bool isDataLoaded = false;
  String errorMsg = "";

  Future<PetDetails> getDataFromJson() async {
    try {
      String response = await rootBundle.loadString('assets/petDetailsData.json');
      PetDetails petDetailsRead = petDetailsFromJson(response);
      return petDetailsRead;
    } catch (e) {
      errorMsg = "Error: Couldn't Read or Find File.";
      return PetDetails(data: []);
    }
  }
/*
  assignData() async {
    petDetails = petDetailsFromJson(await FileManager().getJsonString());
    setState(() {
      isDataLoaded = true;
    });
  }

  @override
  void initState() {
    assignData();
    super.initState();
  }*/
  @override
  void didChangeDependencies() {
    void assignData2() async {
      print("running");
      petDetails = petDetailsFromJson(await context.read<FileController>().readString());
      setState(() {
        isDataLoaded = true;
      });
    }
    assignData2();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return !isDataLoaded ? const Center(child: CircularProgressIndicator(),) :
           errorMsg.isNotEmpty ? Center(child: Text(errorMsg)) : 
     Center(
       child: ListView.builder(
         itemCount: petDetails.data.length + 1,
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
    if (index < petDetails.data.length && petDetails.data.isNotEmpty) {
      return PetCard(pet: petDetails.data[index], petIndex: index,);
    }
    else {
      return const AddPetCard();
    }
  }
}