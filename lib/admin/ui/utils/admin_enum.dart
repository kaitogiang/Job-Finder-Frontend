//Enum dùng để thêm vào bộ lọc trong quản lý jobposting, lọc theo thời gian
enum FilterByTime {
  all('Toàn thời gian'),
  recently24h('Trong vòng 24h'), //trong vòng 24h
  recently7days('Trong vòng 7 ngày'), //trong vòng 7 ngày qua
  recently30days('Trong vòng 30 ngày'); //Trong vòng 30 ngày qua

  final String value;
  const FilterByTime(this.value);
}

//Lọc bài đăng dựa vào trạng thái của bài đăng, còn hạn hay hết hạn
enum FilterByJobpostingStatus {
  all('Tất cả'), //Hiển thị tất cả trạng thái gồm còn hạn và hết hạn
  active('Còn hạn'), //Chỉ hiển thị bài đăng còn hạn
  expired('Hết hạn'); //Chỉ hiển thị bài đăng hết hạn

  final String value;
  const FilterByJobpostingStatus(this.value);
}

//Lọc bài đăng dựa vào trình độ yêu cầu của công việc
enum FilterByJobLevel {
  all('Tất cả'),
  intern('Intern'),
  fresher('Fresher'),
  junior('Junior'),
  middle('Middle'),
  senior('Senior'),
  manager('Manager'),
  leader('Leader');

  final String value;
  const FilterByJobLevel(this.value);
}

//Enum cho biết trạng thái của hồ sơ ứng tuyển của ứng viên bên
//admin

enum ApplicationState {
  accepted,
  rejected,
  pending,
}

//Enum cho biết loại biểu đồ của "Tổng người dùng đăng ký"
enum ChartTypeInUserStats {
  barChart('Biểu đồ cột'),
  lineChart('Biểu đồ đường');

  final String value;
  const ChartTypeInUserStats(this.value);
}

//Enum cho biết mốc thời gian của "Tổng người dùng đăng ký"
enum TimeRange {
  thisWeek('Tuần này'),
  thisMonth('Tháng này'),
  thisYear('Năm này');

  final String value;
  const TimeRange(this.value);
}

//Enum cho biết mốc thời gian của "Công việc mới được đăng tải"
enum JobPostTimeRange {
  past7Days('7 ngày qua'), // 7 ngày qua
  past4Weeks('4 tuần qua'), // 4 tuần qua
  past5Month('5 tháng qua'); // 5 tháng qua

  final String value;
  const JobPostTimeRange(this.value);
}
