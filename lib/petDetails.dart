// To parse this JSON data, do
//
//     final petDetails = petDetailsFromJson(jsonString);

import 'dart:convert';

PetDetails petDetailsFromJson(String str) => PetDetails.fromJson(json.decode(str));

String petDetailsToJson(PetDetails data) => json.encode(data.toJson());

class PetDetails {
  PetDetails({
    required this.data,
  });

  final List<Datum> data;

  factory PetDetails.fromJson(Map<String, dynamic> json) => PetDetails(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.petName,
    required this.petImage,
  });

  final int id;
  final String petName;
  final String petImage;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        petName: json["petName"],
        petImage: json["petImage"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "petName": petName,
        "petImage": petImage,
      };
}