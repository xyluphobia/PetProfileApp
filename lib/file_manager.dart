import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static FileManager? _instance;

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

  Future<String> getJsonString() async {
    final file = await _localFile;
    if (await file.exists()) {
      final contents = await file.readAsString();
      return contents;
    } 
    else {
      // create the file at the correct location then return it
      return "No File";
    }
  }

  Future<void> writeJsonFile(String jsonToSet) async {
    final file = await _localFile;
    file.writeAsString(jsonToSet);
  }
}