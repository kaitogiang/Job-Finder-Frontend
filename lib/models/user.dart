import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class User {
  final String id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  String avatar;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.address,
      required this.avatar});

  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //       id: json['id'],
  //       firstName: json['first_name'],
  //       lastName: json['last_name'],
  //       email: json['email'],
  //       phone: json['phone'],
  //       address: json['address'],
  //       avatar: json['avatar']);
  // }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['_id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        avatar: json['avatar']);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'avatar': avatar
    };
  }

  String getImageUrl({String? uri}) {
    uri ??= kIsWeb
        ? dotenv.env['DATABASE_BASE_URL_WEB']
        : dotenv.env['DATABASE_BASE_URL'];
    return uri! + avatar;
  }
}
