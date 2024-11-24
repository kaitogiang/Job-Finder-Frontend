class UserRegistrationData {
  final String label; //Nhãn để hiển thị mốc thời gian
  final double jobseekerCount; //Số lượng ứng viên trong thời gian nhất định
  final double employerCount; //số lượng nhà tuyển dụng đăng ký
  UserRegistrationData(
      {required this.label,
      required this.jobseekerCount,
      required this.employerCount});
  factory UserRegistrationData.fromJson(Map<String, dynamic> json) {
    return UserRegistrationData(
      label: json['label'],
      jobseekerCount: json['jobseekerCount'],
      employerCount: json['employerCount'],
    );
  }
}
