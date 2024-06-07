import 'dart:convert';
import 'dart:typed_data';

enum HomeType {
  APARTMENT,
  CHALET,
}

class User {
  final int? id;
  final String name;
  final String password;
  final int? phone;
  final int? zipCode;
  final String? description;
  final bool? pets;
  final bool? kids;
  final HomeType? home;
  final Uint8List? profileImage;

  final List<dynamic> statements;
  final List<dynamic> messages;
  final List<dynamic> reachedShelters;
  final List<dynamic> matchedShelters;
  final List<dynamic> likedPets;

  User({
    this.id,
    required this.name,
    required this.password,
    this.phone,
    this.zipCode,
    this.description,
    this.pets,
    this.kids,
    this.home,
    this.profileImage,
    this.statements = const [],
    this.messages = const [],
    this.reachedShelters = const [],
    this.matchedShelters = const [],
    this.likedPets = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'phone': phone,
      'zipCode': zipCode,
      'description': description,
      'pets': pets,
      'kids': kids,
      'home': home != null ? home.toString().split('.').last : null,
      'profileImage': profileImage != null ? base64Encode(profileImage!) : null, 
      'statements': statements,
      'messages': messages,
      'reachedShelters': reachedShelters,
      'matchedShelters': matchedShelters,
      'likedPets': likedPets,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      password: json['password'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] is int ? json['phone'] : int.tryParse(json['phone'] ?? '0'),
      zipCode: json['zipCode'] is int ? json['zipCode'] : int.tryParse(json['zipCode'] ?? '0'),
      pets: json['pets'] ?? false,
      kids: json['kids'] ?? false,
      home: json['home'] != null ? HomeType.values.firstWhere((e) => e.toString().split('.').last == json['home']) : null,
      profileImage: json['profileImage'] != null ? base64Decode(json['profileImage']) : null, 
      statements: json['statements'] ?? [],
      messages: json['messages'] ?? [],
      reachedShelters: json['reachedShelters'] ?? [],
      matchedShelters: json['matchedShelters'] ?? [],
      likedPets: json['likedPets'] ?? [],
    );
  }
}
