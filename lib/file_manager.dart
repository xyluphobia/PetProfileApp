import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_profile_app/account_details.dart';
import 'package:pet_profile_app/pet_details.dart';

class FileManager {
  static FileManager? _instance;
  static String baseJsonString = "{\"data\":[]}";

  FileManager._internal() {
    _instance = this;
  }

  factory FileManager() => _instance ?? FileManager._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localPetFile async {
    final path = await _localPath;
    return File('$path/petDetailsData.json');
  }

  Future<File> get _localAccountFile async {
    final path = await _localPath;
    return File('$path/accountData.json');
  }

  Future<String> readJsonFile(bool petFile) async {
    final file = petFile ? await _localPetFile : await _localAccountFile;
    bool doesFileExist = await file.exists();

    if (!doesFileExist) {
      // create the file at the correct location if it doesn't exist then return it
      await file.create();
      petFile ? await writeJsonFile(true, baseJsonString) : await writeJsonFile(false, "{}");
    } 

    final contents = await file.readAsString();
    return contents;
  }

  Future<dynamic> writeJsonFile(bool petFile, String jsonToSet) async {
    final file = petFile ? await _localPetFile : await _localAccountFile;
    file.writeAsString(jsonToSet);
    return petFile ? petDetailsFromJson(jsonToSet) : Account.fromJson(jsonDecode(jsonToSet));
  }

  Future<String> saveImage(File image) async {
    final path = await _localPath;
    File imageSaved = await image.copy('$path/${DateTime.now()}');
    return imageSaved.path;
  }

  Future<int> deleteFile(String? path) async {
    if (path == null) {
      if (kDebugMode) print("Null path passed to delete.");
      return 0;
    }

    try {
      File file = File(path);
      await file.delete();
      return 1;
    }
    catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 0;
    }
  }
}