class ApplicationStatsData {
  final String label;
  final int receivedApplicationCount;
  final int approvedApplicationCount;
  final int rejectedApplicationCount;

  const ApplicationStatsData({
    required this.label,
    required this.receivedApplicationCount,
    required this.approvedApplicationCount,
    required this.rejectedApplicationCount,
  });

  factory ApplicationStatsData.fromJson(Map<String, dynamic> json) {
    return ApplicationStatsData(
      label: json['label'],
      receivedApplicationCount: json['receivedApplicationCount'],
      approvedApplicationCount: json['approvedApplicationCount'],
      rejectedApplicationCount: json['rejectedApplicationCount'],
    );
  }
}
