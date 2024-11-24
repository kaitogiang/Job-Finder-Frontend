import 'package:job_finder_app/models/application_stats_data.dart';
import 'package:job_finder_app/models/job_count_data.dart';
import 'package:job_finder_app/models/user_registration_data.dart';

List<UserRegistrationData> dailyData = [
  UserRegistrationData(label: "05/11", jobseekerCount: 0.0, employerCount: 0.0),
  UserRegistrationData(
      label: "06/11", jobseekerCount: 50.0, employerCount: 38.0),
  UserRegistrationData(
      label: "07/11", jobseekerCount: 60.0, employerCount: 40.0),
  UserRegistrationData(
      label: "08/11", jobseekerCount: 35.0, employerCount: 28.0),
  UserRegistrationData(
      label: "09/11", jobseekerCount: 42.0, employerCount: 35.0),
  UserRegistrationData(
      label: "10/11", jobseekerCount: 38.0, employerCount: 30.0),
  UserRegistrationData(
      label: "11/11", jobseekerCount: 48.0, employerCount: 33.0),
];

List<UserRegistrationData> weeklyData = [
  UserRegistrationData(
      label: "Tuần 1", jobseekerCount: 250.0, employerCount: 200.0),
  UserRegistrationData(
      label: "Tuần 2", jobseekerCount: 300.0, employerCount: 250.0),
  UserRegistrationData(
      label: "Tuần 3", jobseekerCount: 280.0, employerCount: 230.0),
  UserRegistrationData(
      label: "Tuần 4", jobseekerCount: 320.0, employerCount: 270.0),
];

List<UserRegistrationData> monthlyData = [
  UserRegistrationData(
      label: "Tháng 01", jobseekerCount: 1200.0, employerCount: 800.0),
  UserRegistrationData(
      label: "Tháng 02", jobseekerCount: 1100.0, employerCount: 750.0),
  UserRegistrationData(
      label: "Tháng 03", jobseekerCount: 1300.0, employerCount: 850.0),
  UserRegistrationData(
      label: "Tháng 04", jobseekerCount: 1400.0, employerCount: 900.0),
  UserRegistrationData(
      label: "Tháng 05", jobseekerCount: 1500.0, employerCount: 950.0),
  UserRegistrationData(
      label: "Tháng 06", jobseekerCount: 1350.0, employerCount: 800.0),
  UserRegistrationData(
      label: "Tháng 07", jobseekerCount: 1450.0, employerCount: 900.0),
  UserRegistrationData(
      label: "Tháng 08", jobseekerCount: 1600.0, employerCount: 950.0),
  UserRegistrationData(
      label: "Tháng 09", jobseekerCount: 1250.0, employerCount: 780.0),
  UserRegistrationData(
      label: "Tháng 10", jobseekerCount: 1550.0, employerCount: 1000.0),
  UserRegistrationData(
      label: "Tháng 11", jobseekerCount: 1400.0, employerCount: 920.0),
  UserRegistrationData(
      label: "Tháng 12", jobseekerCount: 1300.0, employerCount: 850.0),
];

// Dữ liệu thống kê công việc theo ngày (7 ngày qua)
List<JobCountData> jobDailyData = [
  JobCountData(label: '01/11', jobCount: 15),
  JobCountData(label: '02/11', jobCount: 20),
  JobCountData(label: '03/11', jobCount: 10),
  JobCountData(label: '04/11', jobCount: 25),
  JobCountData(label: '05/11', jobCount: 18),
  JobCountData(label: '06/11', jobCount: 22),
  JobCountData(label: '07/11', jobCount: 30),
];

// Dữ liệu thống kê công việc theo tuần (4 tuần qua)
List<JobCountData> jobWeeklyData = [
  JobCountData(label: '09/10 - 15/10', jobCount: 80),
  JobCountData(label: '16/10 - 22/10', jobCount: 95),
  JobCountData(label: '23/10 - 29/10', jobCount: 110),
  JobCountData(label: '30/10 - 05/11', jobCount: 90),
];

// Dữ liệu thống kê công việc theo tháng (6 tháng qua)
List<JobCountData> jobMonthlyData = [
  JobCountData(label: 'Tháng 6', jobCount: 300),
  JobCountData(label: 'Tháng 7', jobCount: 350),
  JobCountData(label: 'Tháng 8', jobCount: 320),
  JobCountData(label: 'Tháng 9', jobCount: 400),
  JobCountData(label: 'Tháng 10', jobCount: 380),
  JobCountData(
      label: 'Tháng 11', jobCount: 120), // Dữ liệu đến thời điểm hiện tại
];

List<ApplicationStatsData> weeklyApplicationStats = [
  ApplicationStatsData(
    label: '01/11',
    receivedApplicationCount: 8,
    approvedApplicationCount: 4,
    rejectedApplicationCount: 2,
  ),
  ApplicationStatsData(
    label: '02/11',
    receivedApplicationCount: 12,
    approvedApplicationCount: 5,
    rejectedApplicationCount: 3,
  ),
  ApplicationStatsData(
    label: '03/11',
    receivedApplicationCount: 10,
    approvedApplicationCount: 3,
    rejectedApplicationCount: 4,
  ),
  ApplicationStatsData(
    label: '04/11',
    receivedApplicationCount: 14,
    approvedApplicationCount: 6,
    rejectedApplicationCount: 2,
  ),
  ApplicationStatsData(
    label: '05/11',
    receivedApplicationCount: 8,
    approvedApplicationCount: 3,
    rejectedApplicationCount: 1,
  ),
  ApplicationStatsData(
    label: '06/11',
    receivedApplicationCount: 6,
    approvedApplicationCount: 2,
    rejectedApplicationCount: 2,
  ),
  ApplicationStatsData(
    label: '07/11',
    receivedApplicationCount: 7,
    approvedApplicationCount: 4,
    rejectedApplicationCount: 3,
  ),
];

// Dữ liệu thống kê trạng thái ứng tuyển cho từng tuần trong tháng này
List<ApplicationStatsData> monthlyApplicationStats = [
  ApplicationStatsData(
    label: 'Tuần 1',
    receivedApplicationCount: 40,
    approvedApplicationCount: 15,
    rejectedApplicationCount: 8,
  ),
  ApplicationStatsData(
    label: 'Tuần 2',
    receivedApplicationCount: 45,
    approvedApplicationCount: 18,
    rejectedApplicationCount: 10,
  ),
  ApplicationStatsData(
    label: 'Tuần 3',
    receivedApplicationCount: 50,
    approvedApplicationCount: 22,
    rejectedApplicationCount: 12,
  ),
  ApplicationStatsData(
    label: 'Tuần 4',
    receivedApplicationCount: 35,
    approvedApplicationCount: 15,
    rejectedApplicationCount: 5,
  ),
];

List<ApplicationStatsData> yearlyApplicationStats = [
  ApplicationStatsData(
    label: 'Tháng 1',
    receivedApplicationCount: 300,
    approvedApplicationCount: 120,
    rejectedApplicationCount: 50,
  ),
  ApplicationStatsData(
    label: 'Tháng 2',
    receivedApplicationCount: 250,
    approvedApplicationCount: 110,
    rejectedApplicationCount: 40,
  ),
  ApplicationStatsData(
    label: 'Tháng 3',
    receivedApplicationCount: 280,
    approvedApplicationCount: 130,
    rejectedApplicationCount: 60,
  ),
  ApplicationStatsData(
    label: 'Tháng 4',
    receivedApplicationCount: 320,
    approvedApplicationCount: 140,
    rejectedApplicationCount: 70,
  ),
  ApplicationStatsData(
    label: 'Tháng 5',
    receivedApplicationCount: 350,
    approvedApplicationCount: 150,
    rejectedApplicationCount: 80,
  ),
  ApplicationStatsData(
    label: 'Tháng 6',
    receivedApplicationCount: 300,
    approvedApplicationCount: 130,
    rejectedApplicationCount: 60,
  ),
  ApplicationStatsData(
    label: 'Tháng 7',
    receivedApplicationCount: 330,
    approvedApplicationCount: 140,
    rejectedApplicationCount: 65,
  ),
  ApplicationStatsData(
    label: 'Tháng 8',
    receivedApplicationCount: 310,
    approvedApplicationCount: 135,
    rejectedApplicationCount: 55,
  ),
  ApplicationStatsData(
    label: 'Tháng 9',
    receivedApplicationCount: 320,
    approvedApplicationCount: 145,
    rejectedApplicationCount: 60,
  ),
  ApplicationStatsData(
    label: 'Tháng 10',
    receivedApplicationCount: 300,
    approvedApplicationCount: 130,
    rejectedApplicationCount: 50,
  ),
  ApplicationStatsData(
    label: 'Tháng 11',
    receivedApplicationCount: 340,
    approvedApplicationCount: 150,
    rejectedApplicationCount: 70,
  ),
  ApplicationStatsData(
    label: 'Tháng 12',
    receivedApplicationCount: 0, // Tháng chưa tới, ghi là 0
    approvedApplicationCount: 0, // Tháng chưa tới, ghi là 0
    rejectedApplicationCount: 0, // Tháng chưa tới, ghi là 0
  ),
];
