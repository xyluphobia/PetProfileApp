
class Account {
  Account({
    this.lastLatLng,
    this.image,
    this.name,
    this.homeAddress,
    this.vetAddress, 
  });

  String? lastLatLng;
  String? image;
  String? name;
  String? homeAddress;
  String? vetAddress;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    lastLatLng: json["lastLatLng"],
    image: json["image"],
    name: json["name"],
    homeAddress: json["homeAddress"], 
    vetAddress: json["vetAddress"], 
  );

  Map<String, dynamic> toJson() => {
    "lastLatLng": lastLatLng,
    "image": image,
    "name": name,
    "homeAddress": homeAddress,
    "vetAddress": vetAddress,
  };
}