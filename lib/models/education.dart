class Education {
  final String specialization;
  final String school;
  final String degree;
  final DateTime startDate;
  final DateTime endDate;

  Education({
    required this.specialization,
    required this.school,
    required this.degree,
    required this.startDate,
    required this.endDate,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      specialization: json['specialization'],
      school: json['school'],
      degree: json['degree'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialization': specialization,
      'school': school,
      'degree': degree,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}