class JobCountData {
  final String label;
  final double jobCount;

  const JobCountData({required this.label, required this.jobCount});

  factory JobCountData.fromJson(Map<String, dynamic> json) {
    return JobCountData(
      label: json['label'],
      jobCount: json['jobCount'] as double,
    );
  }
}
