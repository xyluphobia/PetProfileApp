// To parse this JSON data, do
//
//     final petDetails = petDetailsFromJson(jsonString);

import 'dart:convert';

// ignore: constant_identifier_names, non_constant_identifier_names

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
    this.notOwnedByAccount = false,
    this.image,
    this.name,
    this.age,
    this.birthday,
    this.gender,
    this.species,
    this.breed,
    this.owner,

    List<String>? petFoods
  }) : petFoods = petFoods ?? <String>[];

  bool notOwnedByAccount;
  String? image;
  String? name;
  String? age;
  String? birthday;
  String? gender;
  String? species;
  String? breed;
  String? owner;

  List<String> petFoods;

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    notOwnedByAccount: json["notOwnedByAccount"],
    image: json["image"],
    name: json["name"],
    age: json["age"],
    birthday: json["birthday"],
    gender: json["gender"],
    species: json["species"],
    breed: json["breed"],
    owner: json["owner"],

    petFoods: List<String>.from(json["petFoods"]),
  );

  Map<String, dynamic> toJson() => {
    "notOwnedByAccount": notOwnedByAccount,
    "image": image,
    "name": name,
    "age": age,
    "birthday": birthday,
    "gender": gender,
    "species": species,
    "breed": breed,
    "owner": owner,

    "petFoods": petFoods, 
  };
}