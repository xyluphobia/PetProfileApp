import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/petDetails.dart';

class FileController extends ChangeNotifier
{
  PetDetails? _petDetails;
  PetDetails? get petDetails => _petDetails;

  readPetDetails() async {
    _petDetails = petDetailsFromJson(await FileManager().readJsonFile());
    notifyListeners();
  }

  writePetDetails(PetDetails dataToWrite) async {
    _petDetails = await FileManager().writeJsonFile(petDetailsToJson(dataToWrite));
    notifyListeners();
  }

  clearPetDetailsJson() async {
    _petDetails = await FileManager().writeJsonFile(FileManager.baseJsonString);
    notifyListeners();
  }
}