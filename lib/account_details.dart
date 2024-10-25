
class Account {
  Account({
    this.lastLatLng,
    this.name,
    this.contactNumber,

    VetNumAndAddress? preferredVetAddress, 
    VetNumAndAddress? emergencyVetAddress, 
  }) : preferredVet = preferredVetAddress ?? VetNumAndAddress(),
       emergencyVet = emergencyVetAddress ?? VetNumAndAddress();

  String? lastLatLng;
  String? name;
  String? contactNumber;

  VetNumAndAddress preferredVet;
  VetNumAndAddress emergencyVet;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    lastLatLng: json["lastLatLng"],
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
    "lastLatLng": lastLatLng,
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