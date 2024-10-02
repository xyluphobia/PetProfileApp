
class Account {
  Account({
    this.lastLatLng,
    this.name,
    this.contactNumber,

    this.preferredVetAddress, 
    this.emergencyVetAddress, 
  });

  String? lastLatLng;
  String? name;
  String? contactNumber;

  String? preferredVetAddress;
  String? emergencyVetAddress;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    lastLatLng: json["lastLatLng"],
    name: json["name"],
    contactNumber: json["contactNumber"],

    preferredVetAddress: json["preferredVetAddress"], 
    emergencyVetAddress: json["emergencyVetAddress"], 
  );

  Map<String, dynamic> toJson() => {
    "lastLatLng": lastLatLng,
    "name": name,
    "contactNumber": contactNumber, 
    
    "preferredVetAddress": preferredVetAddress,
    "emergencyVetAddress": emergencyVetAddress,
  };
}