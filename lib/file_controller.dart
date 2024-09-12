import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pet_profile_app/account_details.dart';
import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/pet_details.dart';

class FileController extends ChangeNotifier
{
  PetDetails? _petDetails;
  PetDetails? get petDetails => _petDetails;

  readPetDetails() async {
    _petDetails = petDetailsFromJson(await FileManager().readJsonFile(true));
    notifyListeners();
  }
  writePetDetails(PetDetails dataToWrite) async {
    _petDetails = await FileManager().writeJsonFile(true, petDetailsToJson(dataToWrite));
    notifyListeners();
  }
  clearPetDetailsJson() async {
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
    _accountDetails = await FileManager().writeJsonFile(false, "{}");
    notifyListeners();
  }
}