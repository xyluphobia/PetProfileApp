import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/petDetails.dart';

class FileController extends ChangeNotifier
{
  String? _string;
  String? get string => _string;

  Future<String> readString() async {
    String LocalString = await FileManager().readJsonFile();
    notifyListeners();
    return LocalString;
  }

  writeString(String jsonToSet) async {
    await FileManager().writeJsonFile(jsonToSet);
    notifyListeners();
  }

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
}