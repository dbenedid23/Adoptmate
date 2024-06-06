import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

class Pet {
  final String name;
  final String sex;
  final int age;
  final String description;
  final String shelterName;
  final String breedName;
 

  Pet({
    required this.name,
    required this.sex,
    required this.age,
    required this.description,
    required this.shelterName,
    required this.breedName,
    //this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sex': sex,
      'age': age,
      'description': description,
      'shelterName': shelterName,
      'breedName': breedName,
      //'image': image != null ? base64Encode(image!) : null,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      name: json['name'],
      sex: json['sex'],
      age: json['age'],
      description: json['description'],
      shelterName: json['shelterName'],
      breedName: json['breedName'],
      //image: json['image'] != null ? base64Decode(json['image']) : null,
    );
  }
}
