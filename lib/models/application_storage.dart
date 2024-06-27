import 'dart:developer';

import 'package:job_finder_app/models/jobposting.dart';

import 'application.dart';

class ApplicationStorage {
  final String id;
  Jobposting jobposting;
  List<Application> applications;
  String deadline;

  ApplicationStorage({
    required this.id,
    required this.jobposting,
    required this.applications,
    required this.deadline,
  });

  String get getMonthAndYearString {
    final date = DateTime.parse(deadline);
    return '${date.month}/${date.year}';
  }

  DateTime get deadlineDate => DateTime.parse(deadline);

  List<Application> get approvedApplications =>
      applications.where((app) => app.status == 1).toList();

  List<Application> get rejectedApplications =>
      applications.where((app) => app.status == 2).toList();

  int get applicationNumber => applications.length;

  int get passApplicationNumber =>
      applications.where((app) => app.status == 1).toList().length;

  int get failApplicationNumber =>
      applications.where((app) => app.status == 2).toList().length;

  int get consideredApplicationNumber =>
      applications.where((app) => app.status != 0).toList().length;

  bool get isCompletedApplications {
    return applicationNumber == consideredApplicationNumber;
  }

  bool isTheSameMonthAndYear(String dateString) {
    final date = DateTime.parse(dateString);
    final deadlineDate = DateTime.parse(deadline);
    return date.month == deadlineDate.month && date.year == deadlineDate.year;
  }

  factory ApplicationStorage.fromJson(Map<String, dynamic> json) {
    log('Du lieu trong jobposting: ${json['deadline'].toString()}');
    return ApplicationStorage(
      id: json['_id'],
      jobposting: Jobposting.fromJson(json['jobposting']),
      applications: List<Application>.from(
          json['applications'].map((x) => Application.fromJson(x))),
      deadline: json['deadline'],
    );
  }
}
