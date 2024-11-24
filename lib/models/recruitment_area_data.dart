import 'package:job_finder_app/admin/ui/utils/vietname_provinces.dart';
import 'package:job_finder_app/models/provinece_location.dart';

class RecruitmentAreaData {
  final ProvinceLocation location;
  final int jobpostingCount;
  final int companyCount;

  RecruitmentAreaData({
    required this.location,
    required this.jobpostingCount,
    required this.companyCount,
  });

  factory RecruitmentAreaData.fromJson(Map<String, dynamic> json) {
    //Tìm kiếm tọa độ ứng với tỉnh/thành phố và tạo đối tượng ProvinceLocation
    ProvinceLocation location =
        VietNameProvinces.getProvinceLocation(json['location']);
    return RecruitmentAreaData(
      location: location,
      jobpostingCount: json['jobpostingCount'],
      companyCount: json['companyCount'],
    );
  }
}
