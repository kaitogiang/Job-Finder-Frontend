import 'dart:developer';

class Application {
  String jobseekerId;
  String name;
  String email;
  String phone;
  String resume;
  int status;

  Application(
      {required this.jobseekerId,
      required this.name,
      required this.email,
      required this.phone,
      required this.resume,
      required this.status});
  factory Application.fromJson(Map<String, dynamic> json) {
    log('FromJson cua Application: ${json.toString()}');
    return Application(
      jobseekerId: json['jobseekerId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      resume: json['resume'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobseekerId': jobseekerId,
      'name': name,
      'email': email,
      'phone': phone,
      'resume': resume,
      'status': status,
    };
  }
}
