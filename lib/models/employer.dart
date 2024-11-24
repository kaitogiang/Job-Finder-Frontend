import 'package:job_finder_app/models/user.dart';

class Employer extends User {
  final String companyId;
  final String role;
  Employer(
      {required super.id,
      required super.firstName,
      required super.lastName,
      required super.email,
      required super.phone,
      required super.address,
      required super.avatar,
      required this.companyId,
      required this.role});

  factory Employer.fromJson(Map<String, dynamic> json) {
    return Employer(
        id: json['_id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        avatar: json['avatar'],
        companyId: json['companyId'],
        role: json['role']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'avatar': avatar,
      'companyId': companyId,
    };
  }

  Employer copyWith(
      {String? firstName,
      String? lastName,
      String? email,
      String? phone,
      String? address,
      String? avatar,
      String? role}) {
    return Employer(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        avatar: avatar ?? this.avatar,
        companyId: companyId,
        role: role ?? this.role);
  }

  @override
  String toString() {
    return '$id $firstName $lastName $email $phone $address $avatar $companyId $role';
  }
}
