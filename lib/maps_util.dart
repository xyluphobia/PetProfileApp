import 'package:pet_profile_app/network_util.dart';
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