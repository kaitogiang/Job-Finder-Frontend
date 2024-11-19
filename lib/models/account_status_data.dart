class AccountStatusData {
  final int activeJobseeker;
  final int activeEmployer;
  final int lockedJobseeker;
  final int lockedEmployer;

  const AccountStatusData(
      {required this.activeJobseeker,
      required this.activeEmployer,
      required this.lockedEmployer,
      required this.lockedJobseeker});
  factory AccountStatusData.fromJson(Map<String, dynamic> json) {
    return AccountStatusData(
      activeJobseeker: json['activeJobseeker'],
      activeEmployer: json['activeEmployer'],
      lockedEmployer: json['lockedEmployer'],
      lockedJobseeker: json['lockedJobseeker'],
    );
  }
}
