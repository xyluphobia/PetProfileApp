
class Account {
  Account({
    this.lastLatLng,
    this.image,
    this.name,
    this.homeAddress,
    this.preferredVetAddress, 
    this.emergencyVetAddress, 
  });

  String? lastLatLng;
  String? image;
  String? name;
  String? homeAddress;

  String? preferredVetAddress;
  String? emergencyVetAddress;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    lastLatLng: json["lastLatLng"],
    image: json["image"],
    name: json["name"],
    homeAddress: json["homeAddress"], 
    preferredVetAddress: json["preferredVetAddress"], 
    emergencyVetAddress: json["emergencyVetAddress"], 
  );

  Map<String, dynamic> toJson() => {
    "lastLatLng": lastLatLng,
    "image": image,
    "name": name,
    "homeAddress": homeAddress,
    "preferredVetAddress": preferredVetAddress,
    "emergencyVetAddress": emergencyVetAddress,
  };
}