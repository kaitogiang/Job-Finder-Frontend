import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'company.dart';

class Jobposting {
  final String id;
  String title;
  Document description;
  Document requirements;
  List<String> skills;
  String workLocation;
  String workTime;
  List<String> level;
  Document benefit;
  String deadline;
  String jobType;
  String salary;
  String contractType;
  String experience;
  Company? company;
  String createdAt;
  ValueNotifier<bool> _isFavorite;

  Jobposting({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.workLocation,
    required this.workTime,
    required this.level,
    required this.benefit,
    required this.deadline,
    required this.jobType,
    required this.salary,
    required this.contractType,
    required this.experience,
    required this.createdAt,
    required this.company,
    bool? isFavorite = false,
  }) : _isFavorite = ValueNotifier(isFavorite!);

  ValueNotifier<bool> get favorite => _isFavorite;

  bool get isFavorite => _isFavorite.value;

  set isFavorite(bool value) => _isFavorite.value = value;

  factory Jobposting.fromJson(Map<String, dynamic> json) {
    log('Phia sau lệnh chuyển Document');
    return Jobposting(
        id: json['_id'],
        title: json['title'],
        description: Document.fromJson(json['description']),
        requirements: Document.fromJson(json['requirements']),
        skills: List<String>.from(json['skills']),
        workLocation: json['workLocation'],
        workTime: json['workTime'],
        level: List<String>.from(json['level']),
        benefit: Document.fromJson(json['benefit']),
        deadline: json['deadline'],
        jobType: json['jobType'],
        salary: json['salary'],
        contractType: json['contractType'],
        experience: json['experience'],
        createdAt: json['createdAt'],
        company: Company.fromJson(json['company'] as Map<String, dynamic>));
  }

  Jobposting copyWith({
    String? title,
    Document? description,
    Document? requirements,
    List<String>? skills,
    String? workLocation,
    String? workTime,
    List<String>? level,
    Document? benefit,
    String? deadline,
    String? jobType,
    String? salary,
    String? contractType,
    String? experience,
    Company? company,
    bool? isFavorite,
  }) {
    return Jobposting(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        requirements: requirements ?? this.requirements,
        skills: skills ?? this.skills,
        workLocation: workLocation ?? this.workLocation,
        workTime: workTime ?? this.workTime,
        level: level ?? this.level,
        benefit: benefit ?? this.benefit,
        deadline: deadline ?? this.deadline,
        jobType: jobType ?? this.jobType,
        salary: salary ?? this.salary,
        contractType: contractType ?? this.contractType,
        experience: experience ?? this.experience,
        company: company ?? this.company,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description.toDelta().toJson(),
      'requirements': requirements.toDelta().toJson(),
      'skills': skills,
      'workLocation': workLocation,
      'workTime': workTime,
      'level': level,
      'benefit': benefit.toDelta().toJson(),
      'deadline': deadline,
      'jobType': jobType,
      'salary': salary,
      'contractType': contractType,
      'experience': experience,
    };
  }

  @override
  String toString() {
    return '$title $requirements $skills $workLocation $workTime $level $jobType $salary $contractType $experience $company';
  }
}
