import 'dart:convert';
import 'dart:typed_data';
import 'user.dart';
import 'pet.dart';

class Shelter {
  final String cif;
  final String name;
  final String password;
  final String location;
  final int phone;
  final String? description;
  
  final List<Pet> pets;
 // final List<Message> messages;
  final List<User> reachedUsers;
  final List<User> matchedUsers;

  Shelter({
    required this.cif,
    required this.name,
    required this.password,
    required this.location,
    required this.phone,
    this.description,
    
    this.pets = const [],
    //this.messages = const [],
    this.reachedUsers = const [],
    this.matchedUsers = const [],
    
  });

  Map<String, dynamic> toJson() {
    return {
      'cif': cif,
      'name': name,
      'password': password,
      'location': location,
      'phone': phone,
      'description': description,
      
      'pets': pets.map((pet) => pet.toJson()).toList(),
     // 'messages': messages.map((message) => message.toJson()).toList(),
      'reachedUsers': reachedUsers.map((user) => user.toJson()).toList(),
      'matchedUsers': matchedUsers.map((user) => user.toJson()).toList(),
      
    };
  }

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      cif: json['cif'],
      name: json['name'],
      password: json['password'],
      location: json['location'],
      phone: json['phone'],
      description: json['description'],
      
      pets: (json['pets'] as List).map((item) => Pet.fromJson(item)).toList(),
     // messages: (json['messages'] as List).map((item) => Message.fromJson(item)).toList(),
      reachedUsers: (json['reachedUsers'] as List).map((item) => User.fromJson(item)).toList(),
      matchedUsers: (json['matchedUsers'] as List).map((item) => User.fromJson(item)).toList(),
      
    );
  }
}


