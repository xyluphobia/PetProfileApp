// To parse this JSON data, do
//
//     final petDetails = petDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pet_profile_app/account_details.dart';

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

    List<String>? petFoods,
    List<TimeOfDay>? feedingTimes,
    this.petFoodNotes,

    List<MedicationEntry>? medications,
    List<VaccinationEntry>? vaccinations,
    List<ProcedureEntry>? procedures,

    VetNumAndAddress? sharedPrefVet,
    VetNumAndAddress? sharedEmeVet,
  }) : 
    petFoods = petFoods ?? <String>[],
    feedingTimes = feedingTimes ?? <TimeOfDay>[],
    
    medications = medications ?? <MedicationEntry>[],
    vaccinations = vaccinations ?? <VaccinationEntry>[],
    procedures = procedures ?? <ProcedureEntry>[],

    sharedPrefVet = sharedPrefVet ?? VetNumAndAddress(),
    sharedEmeVet = sharedEmeVet ?? VetNumAndAddress();

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
  List<TimeOfDay> feedingTimes;
  String? petFoodNotes;

  List<MedicationEntry> medications;
  List<VaccinationEntry> vaccinations;  // Name & imagePath string of uploaded vaccination
  List<ProcedureEntry> procedures;  // Name & imagePath string of uploaded procedure
  
  VetNumAndAddress sharedPrefVet;
  VetNumAndAddress sharedEmeVet;

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

    petFoods: List<String>.from(json["petFoods"] ?? []),
    feedingTimes: (json["feedingTimes"] as List<dynamic>?)
      ?.map((item) => TimeOfDay(
          hour: item['hour'] as int, 
          minute: item['minute'] as int))
      .toList() ?? [],
    petFoodNotes: json["petFoodNotes"],

    medications: (json["medications"] as List<dynamic>?)
      ?.map((med) => MedicationEntry(
        name: med['name'] as String,
        time: TimeOfDay(
          hour: med['time']['hour'] as int,
          minute: med['time']['minute'] as int
        ),
        taken: med['taken'] as bool
      ))
      .toList() ?? [],
    vaccinations: (json["vaccinations"] as List<dynamic>?)
      ?.map((vac) => VaccinationEntry(
            name: vac['name'] as String,
            imagePath: vac['imagePath'] as String,
          ))
      .toList() ?? [],
    procedures: (json["procedures"] as List<dynamic>?)
      ?.map((proc) => ProcedureEntry(
            name: proc['name'] as String,
            imagePath: proc['imagePath'] as String,
          ))
      .toList() ?? [],

    sharedPrefVet: json["sharedPrefVet"] != null
      ? VetNumAndAddress.fromJson(json["sharedPrefVet"])
      : null,
    sharedEmeVet: json["sharedEmeVet"] != null
      ? VetNumAndAddress.fromJson(json["sharedEmeVet"])
      : null,
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
    "feedingTimes": feedingTimes
      .map((time) => {
          'hour': time.hour,
          'minute': time.minute,
      })
      .toList(),
    "petFoodNotes": petFoodNotes,

    "medications": medications.map((medEntry) => {
      'name': medEntry.name,
      'time': {
        'hour': medEntry.time.hour,
        'minute': medEntry.time.minute,
      },
      'taken': medEntry.taken,
    }).toList(),
    "vaccinations": vaccinations.map((vacEntry) => {
      'name': vacEntry.name,
      'imagePath': vacEntry.imagePath,
    }).toList(),
    "procedures": procedures.map((procEntry) => {
        'name': procEntry.name,
        'imagePath': procEntry.imagePath,
      }).toList(),

    "sharedPrefVet": sharedPrefVet.toJson(),
    "sharedEmeVet": sharedEmeVet.toJson(),
  };
}

class MedicationEntry {
  String name;
  TimeOfDay time;
  bool taken;

  MedicationEntry({
    required this.name,
    required this.time,
    required this.taken,
  });
}
class VaccinationEntry {
  String name;
  String imagePath;

  VaccinationEntry ({
    required this.name,
    required this.imagePath,
  });
}
class ProcedureEntry {
  String name;
  String imagePath;

  ProcedureEntry({
    required this.name,
    required this.imagePath,
  });
}