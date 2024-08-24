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

  final List<Pet> data;

  factory PetDetails.fromJson(Map<String, dynamic> json) => PetDetails(
        data: List<Pet>.from(json["data"].map((x) => Pet.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Pet {
  Pet({
    required this.name,
    required this.image,
  });

  String name;
  String image;

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        name: json["petName"],
        image: json["petImage"],
      );

  Map<String, dynamic> toJson() => {
        "petName": name,
        "petImage": image,
      };
}