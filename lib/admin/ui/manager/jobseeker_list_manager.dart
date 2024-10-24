import 'package:job_finder_app/admin/ui/utils/sample.dart';
import 'package:flutter/material.dart';

class JobseekerListManager extends ChangeNotifier {
  final List<Map<String, dynamic>> _jobseekersList = jobseekers;

  List<Map<String, dynamic>> getJobseekers() => _jobseekersList;

  //Hàm lấy số lượng phần tử trong danh sách
  int get getJobseekersCount => _jobseekersList.length;

  //Hàm lấy danh sách ứng viên theo nhóm 5 người, pageNumber là số thứ tự nhóm đó bắt đầu từ 1
  //Ví dụ: pageNumber = 1 -> lấy nhóm 1, pageNumber = 2 -> lấy nhóm 2, ...
  //PageNumber - 1 tương đương với index bắt đầu của nhóm 5 người.
  List<Map<String, dynamic>> getJobseekerByPage(int pageNumber, int groupSize) {
    int startIndex = (pageNumber - 1) * groupSize;
    int endIndex = (startIndex + groupSize) > _jobseekersList.length
        ? _jobseekersList.length
        : startIndex + groupSize;
    return _jobseekersList.sublist(startIndex, endIndex);
  }

  //Hàm lấy số lượng nhóm có thể hiển thị trong number pagination,
  //hàm này tự động làm tròn lên số lớn hơn nếu có phần dư
  //Ví dụ 0.1 -> 1, 0.5 -> 1, 0.9 -> 1
  int getTotalGroupCount(int groupSize) {
    return (_jobseekersList.length / groupSize).ceil();
  }
}
