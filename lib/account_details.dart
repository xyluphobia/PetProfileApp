
class Account {
  Account({
    this.lastLatLng,
    this.image,
    this.name,
    this.age,
    this.birthday,
  });

  String? lastLatLng;
  String? image;
  String? name;
  String? age;
  String? birthday;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    lastLatLng: json["lastLatLng"],
    image: json["image"],
    name: json["name"],
    age: json["age"],
    birthday: json["birthday"],
  );

  Map<String, dynamic> toJson() => {
    "lastLatLng": lastLatLng,
    "image": image,
    "name": name,
    "age" : age,
    "birthday" : birthday,
  };
}