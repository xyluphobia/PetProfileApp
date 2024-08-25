import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pet_profile_app/petDetails.dart';

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

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/petDetailsData.json');
  }

  Future<String> readJsonFile() async {
    final file = await _localFile;
    bool doesFileExist = await file.exists();

    if (!doesFileExist) {
      // create the file at the correct location if it doesn't exist then return it
      await file.create();
      await writeJsonFile(baseJsonString);
    } 

    final contents = await file.readAsString();
    return contents;
  }

  Future<PetDetails> writeJsonFile(String jsonToSet) async {
    final file = await _localFile;
    file.writeAsString(jsonToSet);
    return petDetailsFromJson(jsonToSet);
  }
}