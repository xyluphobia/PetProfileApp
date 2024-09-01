import 'dart:convert';

import 'package:flutter/material.dart';
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