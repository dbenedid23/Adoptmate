import 'dart:convert';
import 'dart:typed_data';
import 'user.dart';
import 'pet.dart';

class Shelter {
   final int? id;
  final String cif;
  final String name;
  final String password;
  final String location;
  final int phone;
  final String? description;
  
  final List<Pet> pets;
  final List<dynamic> messages;
  final List<dynamic> reachedUsers;
  final List<dynamic> matchedUsers;

  Shelter({
    this.id,
    required this.cif,
    required this.name,
    required this.password,
    required this.location,
    required this.phone,
    this.description,
    
    this.pets = const [],
    this.messages = const [],
    this.reachedUsers = const [],
    this.matchedUsers = const [],
    
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cif': cif,
      'name': name,
      'password': password,
      'location': location,
      'phone': phone,
      'description': description,
      
      'pets': pets.map((pet) => pet.toJson()).toList(),
      'messages': messages,
      'reachedUsers': reachedUsers,//reachedUsers.map((user) => user.toJson()).toList(),
      'matchedUsers': matchedUsers,//matchedUsers.map((user) => user.toJson()).toList(),
      
    };
  }

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id'] ?? '',
      cif: json['cif'],
      name: json['name'],
      password: json['password'],
      location: json['location'],
      phone: json['phone'],
      description: json['description'],
      
      pets: (json['pets'] as List).map((item) => Pet.fromJson(item)).toList(),
      messages: json['messages'] ?? [],//(json['messages'] as List).map((item) => Message.fromJson(item)).toList(),
      reachedUsers: json['reachedShelters'] ?? [],//(json['reachedUsers'] as List).map((item) => User.fromJson(item)).toList(),
      matchedUsers: json['matchedShelters'] ?? [],//(json['matchedUsers'] as List).map((item) => User.fromJson(item)).toList(),
      
    );
  }
}


