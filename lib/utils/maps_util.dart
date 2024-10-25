import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:pet_profile_app/utils/network_util.dart';
import 'package:pet_profile_app/secrets.dart';


Future<List<AutocompletePrediction>> mapPlaceAutoComplete(String query) async {
  Uri uri = Uri.https(
    "maps.googleapis.com", 
    "/maps/api/place/autocomplete/json",
    {
      "input": query,
      "key": mapsAPI,
    }
  );

  String? response = await NetworkUtil.fetchUrl(uri);
  if (response != null && response.isNotEmpty) {
    PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);
    if(result.predictions != null) {
      return result.predictions!;
    }
  }
  return <AutocompletePrediction>[];
}

Future<String?> mapStaticImageGetter(String? address) async {
  if (address == null || address == "") return null;
  Uri uri = Uri.https(
    "maps.google.com",
    "/maps/api/staticmap",
    {
      "center": address,
      "markers": "size:mid|color:red|$address",
      "zoom": "14",
      "size": "80x80",
      "maptype": "roadmap",
      "style": "feature:all|element:labels.text|visibility:off",
      "format": "JPEG",
      "key": mapsAPI,
    }
  );
  
  final response = await http.post(uri);
  if (response.statusCode == 200)
  {
    final directory = await getApplicationDocumentsDirectory();
    File image = File('${directory.path}/${DateTime.now()}');
    await image.writeAsBytes(response.bodyBytes);
    
    return image.path;
  }
  return null;
}