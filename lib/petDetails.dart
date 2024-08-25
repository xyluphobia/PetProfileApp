// To parse this JSON data, do
//
//     final petDetails = petDetailsFromJson(jsonString);

import 'dart:convert';

// ignore: constant_identifier_names, non_constant_identifier_names
Pet Empty_Pet = Pet(
  name: '', 
  image: '',
  age: 0,
  species: '',
  breed: '',
  owner: '',
);

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
    required this.image,
    required this.name,
    required this.age,
    required this.species,
    required this.breed,
    required this.owner,
  });

  String image;
  String name;
  int age;
  String species;
  String breed;
  String owner;

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        image: json["image"],
        name: json["name"],
        age: json["age"],
        species: json["species"],
        breed: json["breed"],
        owner: json["owner"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "name": name,
        "age" : age,
        "species" : species,
        "breed" : breed,
        "owner" : owner,
      };
}