import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NetworkUtil {
  static Future<String?> fetchUrl(Uri uri, {Map<String, String>? headers, String? jsonRequestBody}) async {
    try {
      final response = await http.post(uri, headers: headers, body: jsonRequestBody);

      if (response.statusCode == 200) {
        return response.body;
      }
    } 
    catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
  
  static Position? lastLocation; //find out how to do this within TOS

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    //lastLocation = await Geolocator.getCurrentPosition();
    return await Geolocator.getCurrentPosition();
  }
}


class PlaceAutocompleteResponse {
  final String? status;
  final List<AutocompletePrediction>? predictions;

  PlaceAutocompleteResponse({this.status, this.predictions});
  
  factory PlaceAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteResponse(
      status: json['status'] as String?,
      predictions: json['predictions']?.map<AutocompletePrediction>((json) => AutocompletePrediction.fromJson(json)).toList(),
    );
  }

  static PlaceAutocompleteResponse parseAutocompleteResult(String responseBody) {
    final parsed = json.decode(responseBody).cast<String, dynamic>();

    return PlaceAutocompleteResponse.fromJson(parsed);
  }
}

class AutocompletePrediction {
  // human-readable name for returned result, i.e. business name
  final String? description;
  // pre-formated text
  final StructuredFormatting? structuredFormatting;
  // unique identifier for a place
  final String? placeId;

  AutocompletePrediction({
    this.description,
    this.structuredFormatting,
    this.placeId,
  });

  factory AutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return AutocompletePrediction(
      description: json['description'] as String?,
      placeId: json['place_id'] as String?,
      structuredFormatting: json['structured_formatting'] != null ? StructuredFormatting.fromJson(json['structured_formatting']) : null,
    );
  }
}

class StructuredFormatting {
  // main text of a prediction, usually name of business
  final String? mainText;
  // secondary text of a prediction
  final String? secondaryText;

  StructuredFormatting({
    this.mainText,
    this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
    );
  }
}

class NearbyVetsResponse {
  final List<NearbyVets>? places;

  NearbyVetsResponse({this.places});
  
  factory NearbyVetsResponse.fromJson(Map<String, dynamic> json) {
    return NearbyVetsResponse(
      places: json['places']?.map<NearbyVets>((json) => NearbyVets.fromJson(json)).toList(),
    );
  }

  static NearbyVetsResponse parseNearbyVetsResult(String responseBody) {
    final parsed = json.decode(responseBody).cast<String, dynamic>();

    return NearbyVetsResponse.fromJson(parsed);
  }
}

class NearbyVets {
  final String? businessName;
  final String? formattedAddress;
  final String? phoneNumber;
  final bool? isOpen;

  NearbyVets({
    this.businessName,
    this.formattedAddress,
    this.phoneNumber,
    this.isOpen,
  });

  factory NearbyVets.fromJson(Map<String, dynamic> json) {
    return NearbyVets(
      businessName: json['displayName']['text'] as String?,
      formattedAddress: json['formattedAddress'] as String?,
      phoneNumber: json['nationalPhoneNumber'] as String?,
      isOpen: json['regularOpeningHours']['openNow'] as bool?,
    );
  }
}