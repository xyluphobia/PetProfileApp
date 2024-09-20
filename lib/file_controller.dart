import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_profile_app/account_details.dart';
import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/pet_details.dart';

class FileController extends ChangeNotifier
{
  /*     Pet Details     */
  PetDetails? _petDetails;
  PetDetails? get petDetails => _petDetails;

  String? checkAndUpdatePetBirthdays({DateTime? birthday, bool updateAll = true}) {
    if (petDetails == null || petDetails?.data == null) return '';

    if (updateAll) {
      for (int i = 0; i < petDetails!.data.length; i++) {
        int expectedAge = DateTime.now().difference(DateFormat('dd/MM/yyyy').tryParse(petDetails!.data[i].birthday!)!).inDays ~/ 365;
        petDetails!.data[i].age = expectedAge.toString();
      }
    }
    else {
      if (birthday == null) return '';

      int expectedAge = DateTime.now().difference(birthday).inDays ~/ 365;
      return expectedAge.toString();
    }
    notifyListeners();
    return null;
  }

  readPetDetails() async {
    _petDetails = petDetailsFromJson(await FileManager().readJsonFile(true));
    notifyListeners();
  }
  writePetDetails(PetDetails dataToWrite) async {
    _petDetails = await FileManager().writeJsonFile(true, petDetailsToJson(dataToWrite));
    notifyListeners();
  }
  clearPetDetailsJson() async {
    if (petDetails?.data != null && petDetails!.data.isNotEmpty){
      for (int i = 0; i < petDetails!.data.length; i++) {
        await FileManager().deleteFile(petDetails!.data[i].image);
      }
    }

    _petDetails = await FileManager().writeJsonFile(true, FileManager.baseJsonString);
    notifyListeners();
  }

  /*     Account Details     */
  Account? _accountDetails;
  Account? get accountDetails => _accountDetails;

  readAccountDetails() async {
    _accountDetails = Account.fromJson(jsonDecode(await FileManager().readJsonFile(false)));
    notifyListeners();
  }
  writeAccountDetails(Account dataToWrite) async {
    _accountDetails = await FileManager().writeJsonFile(false, jsonEncode(dataToWrite.toJson()));
    notifyListeners();
  }
  clearAccountDetailsJson() async {
    await FileManager().deleteFile(accountDetails?.image);
    _accountDetails = await FileManager().writeJsonFile(false, "{}");
    notifyListeners();
  }
}