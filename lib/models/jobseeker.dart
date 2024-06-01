import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/models/resume.dart';

import 'user.dart';

class Jobseeker extends User {
  final List<Resume> _resume;
  final List<String> _skills;
  final List<Experience> _experience;
  final List<Education> _education;

  Jobseeker({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String avatar,
    List<Resume>? resume,
    List<String>? skills,
    List<Experience>? experience,
    List<Education>? education,
  })  : _resume = resume ?? [],
        _skills = skills ?? [],
        _experience = experience ?? [],
        _education = education ?? [],
        super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          address: address,
          avatar: avatar,
        );

  factory Jobseeker.fromJson(Map<String, dynamic> json) {
    return Jobseeker(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar'],
      resume:
          (json['resume'] as List?)?.map((e) => Resume.fromJson(e)).toList() ??
              [],
      skills: json['skills'] ?? [],
      experience: (json['experience'] as List?)
              ?.map((e) => Experience.fromJson(e))
              .toList() ??
          [],
      education: (json['education'] as List?)
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
    );
  }
  //Trả về tất cả CV của một người đã tải lên
  List<Resume> get resume => _resume;
  //Trả về tất cả kỹ năng gồm ngoại ngữ, ngôn ngữ lập trình của
  //một người
  List<String> get skills => _skills;
  //Trả về tất cả những kinh nghiệm của người tìm việc
  List<Experience> get experience => _experience;
  //Trả về học vấn của một người
  List<Education> get education => _education;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'avatar': avatar,
      'resume': resume.map((e) => e.toJson()).toList(),
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
    };
  }

  Jobseeker copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? avatar,
    List<Resume>? resume,
    List<String>? skills,
    List<Experience>? experience,
    List<Education>? education,
  }) {
    return Jobseeker(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      resume: resume ?? this.resume,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
    );
  }

  @override
  String toString() {
    return 'Jobseeker(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, address: $address, avatar: $avatar, resume: $resume, skills: $skills, experience: $experience, education: $education)';
  }
}
