import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Company {
  final String id;
  String companyName;
  String companyEmail;
  String companyPhone;
  String companyAddress;
  String _website;
  String avatar;
  Map<String, String> _description;
  List<String> _images;
  Map<String, String> _contactInformation;
  Map<String, String> _policy;

  Company(
      {required this.id,
      required this.companyName,
      required this.companyEmail,
      required this.companyPhone,
      required this.companyAddress,
      required this.avatar,
      String? website,
      Map<String, String>? description,
      List<String>? images,
      Map<String, String>? contactInformation,
      Map<String, String>? policy})
      : _website = website ?? '',
        _description = description ?? {},
        _images = images ?? [],
        _contactInformation = contactInformation ?? {},
        _policy = policy ?? {};
  Map<String, String>? get description => _description;

  String get website => _website;

  set website(String website) => _website = website;

  List<String> get images => _images;

  set images(List<String> img) => _images = img;

  Map<String, String>? get contactInformation => _contactInformation;

  Map<String, String>? get policy => _policy;

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['_id'],
      companyName: json['companyName'],
      companyEmail: json['companyEmail'],
      companyPhone: json['companyPhone'],
      companyAddress: json['companyAddress'],
      avatar: json['avatar'],
      website: json['website'],
      description: json['description'] != null
          ? descriptionFromJson(json['description'])
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      contactInformation: json['contactInformation'] != null
          ? contactInformationFromJson(json['contactInformation'])
          : null,
      policy: json['policy'] != null ? policyFromJson(json['policy']) : null,
    );
  }

  Company copyWith({
    String? id,
    String? companyName,
    String? companyEmail,
    String? companyPhone,
    String? companyAddress,
    String? website,
    Map<String, String>? description,
    List<String>? images,
    Map<String, String>? contactInformation,
    Map<String, String>? policy,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyEmail: companyEmail ?? this.companyEmail,
      companyPhone: companyPhone ?? this.companyPhone,
      companyAddress: companyAddress ?? this.companyAddress,
      website: website ?? this.website,
      description: description ?? this.description,
      images: images ?? this.images,
      contactInformation: contactInformation ?? this.contactInformation,
      policy: policy ?? this.policy,
      avatar: avatar,
    );
  }

  Map<String, String> toJson() {
    return {
      "companyName": companyName,
      "companyEmail": companyEmail,
      "companyPhone": companyPhone,
      "companyAddress": companyAddress,
      "description": jsonEncode(description),
      "website": website,
      "images": jsonEncode(images),
      "contactInformation": jsonEncode(contactInformation),
      "policy": jsonEncode(policy),
    };
  }

  static Map<String, String>? descriptionFromJson(
      Map<String, dynamic> descInfo) {
    bool isValidKeys = descInfo.containsKey('introduction') ||
        descInfo.containsKey('domain') ||
        descInfo.containsKey('companySize');
    if (!isValidKeys) {
      return null;
    }
    return {
      'introduction': descInfo['introduction'] ?? '',
      'domain': descInfo['domain'] ?? '',
      'companySize': descInfo['companySize'] ?? ''
    };
  }

  String get imageLink => '${dotenv.env['DATABASE_BASE_URL']}$avatar';

  static Map<String, String>? contactInformationFromJson(
      Map<String, dynamic> contactInfo) {
    bool isValidKeys = contactInfo.containsKey('fullName') ||
        contactInfo.containsKey('role') ||
        contactInfo.containsKey('email') ||
        contactInfo.containsKey('phone');
    if (!isValidKeys) {
      return null;
    }
    return {
      'fullName': contactInfo['fullName'] ?? '',
      'role': contactInfo['role'] ?? '',
      'email': contactInfo['email'] ?? '',
      'phone': contactInfo['phone'] ?? ''
    };
  }

  static Map<String, String>? policyFromJson(Map<String, dynamic> policyInfo) {
    bool isValidKeys = policyInfo.containsKey('recruitmentPolicy') ||
        policyInfo.containsKey('employmentPolicy') ||
        policyInfo.containsKey('welfarePolicy');
    if (!isValidKeys) {
      return null;
    }
    return {
      'recruitmentPolicy': policyInfo['recruitmentPolicy'] ?? '',
      'employmentPolicy': policyInfo['employmentPolicy'] ?? '',
      'welfarePolicy': policyInfo['welfarePolicy'] ?? ''
    };
  }
}
