import 'package:flutter/material.dart';
import 'package:pet_profile_app/file_manager.dart';

class FileController extends ChangeNotifier
{
  String? _string;
  String? get string => _string;

  readString() async {
    _string = await FileManager().getJsonString();
    notifyListeners();
    return _string;
  }

  writeString(String jsonToSet) async {
    await FileManager().writeJsonFile(jsonToSet);
    notifyListeners();
  }
}