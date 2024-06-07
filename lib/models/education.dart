class Education {
  final String specialization;
  final String school;
  final String degree;
  final String startDate;
  final String endDate;

  Education({
    required this.specialization,
    required this.school,
    required this.degree,
    required this.startDate,
    required this.endDate,
  });

  Education copyWith({
    String? specialization,
    String? school,
    String? degree,
    String? startDate,
    String? endDate,
  }) {
    return Education(
      specialization: specialization ?? this.specialization,
      school: school ?? this.school,
      degree: degree ?? this.degree,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      specialization: json['specialization'],
      school: json['school'],
      degree: json['degree'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialization': specialization,
      'school': school,
      'degree': degree,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
