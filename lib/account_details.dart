import 'package:geolocator/geolocator.dart';
import 'package:pet_profile_app/utils/network_util.dart';

class Account {
  Account({
    this.lastPosition,
    List<NearbyVets>? nearbyVetsSaved,

    this.name,
    this.contactNumber,

    VetNumAndAddress? preferredVetAddress, 
    VetNumAndAddress? emergencyVetAddress, 
  }) : nearbyVetsSaved = nearbyVetsSaved ?? <NearbyVets>[],
       preferredVet = preferredVetAddress ?? VetNumAndAddress(),
       emergencyVet = emergencyVetAddress ?? VetNumAndAddress();

  Position? lastPosition;
  List<NearbyVets> nearbyVetsSaved;

  String? name;
  String? contactNumber;

  VetNumAndAddress preferredVet;
  VetNumAndAddress emergencyVet;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    lastPosition: json["lastPosition"] != null
      ? Position(
          latitude: json["lastPosition"]["latitude"],
          longitude: json["lastPosition"]["longitude"],
          timestamp: json["lastPosition"]["timestamp"] != null
              ? DateTime.parse(json["lastPosition"]["timestamp"])
              : DateTime.now(),
          accuracy: json["lastPosition"]["accuracy"] ?? 0.0,
          altitude: json["lastPosition"]["altitude"] ?? 0.0,
          heading: json["lastPosition"]["heading"] ?? 0.0,
          speed: json["lastPosition"]["speed"] ?? 0.0,
          speedAccuracy: json["lastPosition"]["speedAccuracy"] ?? 0.0,
          altitudeAccuracy: json["lastPosition"]["altitudeAccuracy"] ?? 0.0,
          headingAccuracy: json["lastPosition"]["headingAccuracy"] ?? 0.0,
        )
      : null,
    nearbyVetsSaved: json["nearbyVetsSaved"] != null
      ? (json["nearbyVetsSaved"] as List)
          .map((item) => NearbyVets.fromJson(item))
          .toList()
      : [],

    name: json["name"],
    contactNumber: json["contactNumber"],

    preferredVetAddress: json["preferredVetAddress"] != null
      ? VetNumAndAddress.fromJson(json["preferredVetAddress"])
      : null,
    emergencyVetAddress: json["emergencyVetAddress"] != null
      ? VetNumAndAddress.fromJson(json["emergencyVetAddress"])
      : null,
  );

  Map<String, dynamic> toJson() => {
    "lastPosition": lastPosition != null
      ? {
          "latitude": lastPosition!.latitude,
          "longitude": lastPosition!.longitude,
          "timestamp": lastPosition!.timestamp.toIso8601String(),
          "accuracy": lastPosition!.accuracy,
          "altitude": lastPosition!.altitude,
          "heading": lastPosition!.heading,
          "speed": lastPosition!.speed,
          "speedAccuracy": lastPosition!.speedAccuracy,
          "altitudeAccuracy": lastPosition!.altitudeAccuracy,
          "headingAccuracy": lastPosition!.headingAccuracy,
        }
      : null,
    "nearbyVetsSaved": nearbyVetsSaved.map((vet) => vet.toJson()).toList(),

    "name": name,
    "contactNumber": contactNumber, 
    
    "preferredVetAddress": preferredVet.toJson(),
    "emergencyVetAddress": emergencyVet.toJson(),
  };
}

class VetNumAndAddress {
  String? phoneNumber;
  String? address;
  String? locationImagePath;

  VetNumAndAddress({
    this.phoneNumber,
    this.address,
    this.locationImagePath,
  });

  
  factory VetNumAndAddress.fromJson(Map<String, dynamic> json) => VetNumAndAddress(
    phoneNumber: json["phoneNumber"],
    address: json["address"],
    locationImagePath: json["locationImagePath"],
  );

  Map<String, dynamic> toJson() => {
    "phoneNumber": phoneNumber,
    "address": address,
    "locationImagePath": locationImagePath,
  };
}