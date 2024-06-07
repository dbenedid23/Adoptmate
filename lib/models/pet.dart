import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

class Pet {
  final int? id;
  final String name;
  final String sex;
  final int age;
  final String description;
  final String shelterName;
  final String breedName;
  final Uint8List? profileImage;

  Pet({
    this.id,
    required this.name,
    required this.sex,
    required this.age,
    required this.description,
    required this.shelterName,
    required this.breedName,
    required this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sex': sex,
      'age': age,
      'description': description,
      'shelterName': shelterName,
      'breedName': breedName,
      'profileImage':  profileImage != null ? base64Encode(profileImage!) : null,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      sex: json['sex'],
      age: json['age'],
      description: json['description'],
      shelterName: json['shelterName'],
      breedName: json['breedName'],
      profileImage: json['profileImage'] != null ? base64Decode(json['profileImage']) : null,
    );
  }
}
