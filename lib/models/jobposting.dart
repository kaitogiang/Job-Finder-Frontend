import 'company.dart';

class Jobposting {
  final String id;
  String title;
  String description;
  String requirements;
  List<String> skills;
  String workLocation;
  String workTime;
  List<String> level;
  String benefit;
  String deadline;
  String jobType;
  String salary;
  String contractType;
  String experience;
  Company? company;
  String createdAt;

  Jobposting(
      {required this.id,
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
      required this.company});

  factory Jobposting.fromJson(Map<String, dynamic> json) {
    return Jobposting(
        id: json['_id'],
        title: json['title'],
        description: json['description'],
        requirements: json['requirements'],
        skills: json['skills'],
        workLocation: json['workLocation'],
        workTime: json['workTime'],
        level: json['level'],
        benefit: json['benefit'],
        deadline: json['deadline'],
        jobType: json['jobType'],
        salary: json['salary'],
        contractType: json['contractType'],
        experience: json['experience'],
        createdAt: json['createdAt'],
        company: Company.fromJson(json['company']));
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'skills': skills,
      'workLocation': workLocation,
      'workTime': workTime,
      'level': level,
      'benefit': benefit,
      'deadline': deadline,
      'jobType': jobType,
      'salary': salary,
      'contractType': contractType,
      'experience': experience,
    };
  }
}
