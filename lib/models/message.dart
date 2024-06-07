import 'dart:convert';
import 'user.dart';
import 'shelter.dart';
class Message {
  final DateTime time;
  final String text;
  final String issuer;
  final User user;
  final Shelter shelter;

  Message({
    required this.time,
    required this.text,
    required this.issuer,
    required this.user,
    required this.shelter,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'text': text,
      'issuer': issuer,
      'user': user.toJson(),
      'shelter': shelter.toJson(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      time: DateTime.parse(json['time']),
      text: json['text'],
      issuer: json['issuer'],
      user: User.fromJson(json['user']),
      shelter: Shelter.fromJson(json['shelter']),
    );
  }
}