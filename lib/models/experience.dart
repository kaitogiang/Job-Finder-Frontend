class Experience {
  final String role;
  final String company;
  final String duration;

  Experience({
    required this.role,
    required this.company,
    required this.duration,
  });

  Experience copyWith({
    String? role,
    String? company,
    String? duration,
  }) {
    return Experience(
      role: role ?? this.role,
      company: company ?? this.company,
      duration: duration ?? this.duration,
    );
  }

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      role: json['role'],
      company: json['company'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'company': company,
      'duration': duration,
    };
  }
}
