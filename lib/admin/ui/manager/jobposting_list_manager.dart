import 'package:flutter/foundation.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/services/jobposting_service.dart';

class JobpostingListManager with ChangeNotifier {
  List<Jobposting> _jobpostings = [];
  List<Jobposting> _recentJobpostings = [];
  List<Jobposting> _filteredJobpostings = [];
//list dùng để lưu trữ kết quả gốc của việc tìm kiếm và lọc
  List<Jobposting> _searchResultJobposting = [];
  List<Jobposting> _filterResultJobposting = [];
  List<Jobposting> _mostFavoriteJobpostings = [];
  //Danh sách chứa các map gồm jobpostingId và favoriteCount,
  //nếu có bất kỳ bài nào có số lượng yêu thích thì sẽ nằm trong list này
  List<Map<String, dynamic>> _favoriteList = [];
  //biến dùng để quan sát là có đang lọc hay tìm kiếm không
  bool _isSearching = false;
  bool _isFiltering = false;
  //List lưu trữ các nhóm giá trị lọc
  List<FilterByTime> _filterByTime = [];
  List<FilterByJobpostingStatus> _filterByStatus = [];
  List<FilterByJobLevel> _filterByLevel = [];
  //Lưu trữ giá trị tìm kiếm
  String _searchText = '';
  //khởi tạo dịch vụ
  final JobpostingService _jobpostingService;

  List<Jobposting> get jobpostings => _jobpostings;
  List<Jobposting> get recentJobpostings => _recentJobpostings;
  List<Jobposting> get filteredJobpostings => _filteredJobpostings;
  List<Jobposting> get filterResultJobposing => _filterResultJobposting;
  List<Jobposting> get searchResultJobposting => _searchResultJobposting;
  List<Jobposting> get mostFavoriteJobpostings => _mostFavoriteJobpostings;

  List<Map<String, dynamic>> get favoriteList => _favoriteList;

  int get mostFavoriteJobpostingsCount => _mostFavoriteJobpostings.length;

  int get jobpostingsCount => _jobpostings.length;

  int get filterJobpostingCount => _filteredJobpostings.length;

  int get activeJobpostingCount {
    return jobpostings
        .where((jobposting) {
          DateTime currentDate = DateTime.now();
          DateTime deadline = DateTime.parse(jobposting.deadline);
          return deadline.isAfter(currentDate);
        })
        .toList()
        .length;
  }

  int get expiredJobpostingCount {
    return jobpostings
        .where((jobposting) {
          DateTime currentDate = DateTime.now();
          DateTime deadline = DateTime.parse(jobposting.deadline);
          return deadline.isBefore(currentDate);
        })
        .toList()
        .length;
  }

  int get recentJobpostingsCount => _recentJobpostings.length;

  int getJobpostingFavoriteCount(String jobpostingId) {
    return favoriteList
        .where((favorite) => favorite['jobpostingId'] == jobpostingId)
        .first['favoriteCount'];
  }

  bool get isSearching => _isSearching;
  bool get isFiltering => _isFiltering;

  set searchText(String value) => _searchText = value;

  set isSearching(bool value) => _isSearching = value;

  set isFiltering(bool value) => _isFiltering = value;

  set filterByTime(List<FilterByTime> value) => _filterByTime = value;

  set filterByStatus(List<FilterByJobpostingStatus> value) =>
      _filterByStatus = value;

  set filterByLevel(List<FilterByJobLevel> value) => _filterByLevel = value;

  set authToken(AuthToken? authToken) {
    _jobpostingService.authToken = authToken;
    notifyListeners();
  }

  //Hàm cập nhật các điều kiện lọc
  void updateFilterValue(
      {required List<FilterByTime> filterByTimeList,
      required List<FilterByJobpostingStatus> filterByStatusList,
      required List<FilterByJobLevel> filterByLevelList}) {
    filterByLevel = filterByLevelList;
    filterByStatus = filterByStatusList;
    filterByLevel = filterByLevelList;
  }

  JobpostingListManager([AuthToken? authToken])
      : _jobpostingService = JobpostingService(authToken);

  //Hàm lấy danh sách ứng viên theo nhóm 5 người, pageNumber là số thứ tự nhóm đó bắt đầu từ 1
  //Ví dụ: pageNumber = 1 -> lấy nhóm 1, pageNumber = 2 -> lấy nhóm 2, ...
  //PageNumber - 1 tương đương với index bắt đầu của nhóm 5 người.
  List<Jobposting> getJobpostingByPage(
      int pageNumber, int groupSize, List<Jobposting> list) {
    int startIndex = (pageNumber - 1) * groupSize;
    int endIndex = (startIndex + groupSize) > list.length
        ? list.length
        : startIndex + groupSize;
    return list.sublist(startIndex, endIndex);
  }

  //Hàm lấy số lượng nhóm có thể hiển thị trong number pagination,
  //hàm này tự động làm tròn lên số lớn hơn nếu có phần dư
  //Ví dụ 0.1 -> 1, 0.5 -> 1, 0.9 -> 1
  int getTotalGroupCount(int groupSize, List<Jobposting> list) {
    return (list.length / groupSize).ceil();
  }

  Future<void> fetchJobpostings() async {
    try {
      _jobpostings = await _jobpostingService.getAllJobpostings();
      _recentJobpostings = await _jobpostingService.getRecentJobpostings();
      _favoriteList = await _jobpostingService.getFavoriteNumberOfJobpostings();
      _filteredJobpostings = [..._jobpostings];
      _searchResultJobposting = [..._filteredJobpostings];
      _filterResultJobposting = [..._filteredJobpostings];
      _filterFavoriteFromOriginalJobposting();
    } catch (error) {
      Utils.logMessage(
          'Error in FetchAllJobposting in JobpostingListManager: $error');
    }
  }

  //Hàm dùng để nhận biết là những jobposting nào được yêu thích, nghĩa là số lượng yêu thích lớn hơn 0
  void _filterFavoriteFromOriginalJobposting() {
    //Lặp qua từng phần tử và xem phần tử nào có lượt yêu thích lớn hơn 0 thì thêm vào mostFavoriteJobpostings
    List<Jobposting> favoriteList = [];
    for (var jobposting in jobpostings) {
      if (_favoriteList
          .any((favorite) => favorite['jobpostingId'] == jobposting.id)) {
        favoriteList.add(jobposting);
      }
    }
    //Sắp xếp theo thứ tự từ lớn đến nhỏ về số lượng yêu thích
    favoriteList.sort((a, b) {
      int favoriteA = getJobpostingFavoriteCount(a.id);
      int favoriteB = getJobpostingFavoriteCount(b.id);
      return favoriteB.compareTo(favoriteA);
    });
    _mostFavoriteJobpostings = favoriteList;
  }

  void searchJobpostings(String searchText) {
    isSearching = true;
    final usedList = isFiltering ? filterResultJobposing : jobpostings;
    String formattedSearchText =
        Utils.removeVietnameseAccent(searchText).toLowerCase();
    final filteredList = usedList.where((jobposting) {
      String formattedString = jobposting.toString().toLowerCase();
      return formattedString.contains(formattedSearchText);
    }).toList();
    //_filteredJobpostings dùng để làm list cập nhật giao diện hiện tại
    _filteredJobpostings = [...filteredList];
    //_searchResultJobposting dùng để lưu trữ kết quả tìm kiếm ban đầu
    _searchResultJobposting = [...filteredList];
    notifyListeners();
  }

  void resetSearch() {
    isSearching = false;
    //Gọi filter lại trong trường hợp, người dùng nhập từ khóa không khớp với dữ liệu dẫn đến danh sách rỗng, sau đó
    //chọn option filter mà option này khớp với một số dữ liệu. Khi xóa từ khóa, thì danh sách phải hiển thị là danh sách
    //khớp với option filter dựa trên danh sách gốc
    if (isFiltering) {
      filterJobposting(_filterByTime, _filterByStatus, _filterByLevel);
    }
    final usedList = isFiltering ? filterResultJobposing : jobpostings;
    _filteredJobpostings = [...usedList];
    _filterResultJobposting = [...usedList];
    //Loại bỏ chuỗi tìm kiếm, sau đó thì lọc lại danh sách
    // if (isFiltering) {
    //   filterJobposting(_filterByTime, _filterByStatus, _filterByLevel);
    // } else {
    //   _filteredJobpostings = [..._jobpostings];
    //   _searchResultJobposting = [..._jobpostings];
    // }
    notifyListeners();
  }

  void resetFilter() {
    isFiltering = false;
    Utils.logMessage('Serach text la: ${_searchText}');
    //Gọi search lại trong trường hợp, người dùng chọn option filter nhưng không có dữ liệu khớp, sau đó họ nhập tìm kiếm, trả về rỗng
    //Khi họ vẫn giữ từ khóa tìm kiếm và xóa filter bỏ thì phải tìm dữ liệu khớp với từ khóa tìm kiếm
    if (isSearching) {
      searchJobpostings(_searchText);
    }
    final usedList = isSearching ? searchResultJobposting : jobpostings;
    _filteredJobpostings = [...usedList];
    _filterResultJobposting = [...usedList];
    notifyListeners();
  }

  void filterJobposting(
      List<FilterByTime> filterByTime,
      List<FilterByJobpostingStatus> filterByStatus,
      List<FilterByJobLevel> filterByLevel) {
    final usedList = isSearching ? searchResultJobposting : jobpostings;
    final isShowAll =
        filterByTime.isEmpty && filterByStatus.isEmpty && filterByLevel.isEmpty;
    //Nếu không có bất kỳ tiêu chí lọc nào thì hiển thị tất cả
    if (isShowAll) {
      resetFilter();
      // isFiltering = false;

      // Utils.logMessage('Hien thi tat ca');
      //Nếu đang search thì khi thì về kết quả tìm kiếm của search không phụ thuộc vào filter,
      //Bình thường, nếu chọn option filter xong và kết quả trả về là rỗng, sau đó người dùng search, lúc này search sẽ dựa vào
      //kết quả tìm kiếm, nhưng bây giờ là rỗng nên search kết quả cũng ra rỗng. Lúc này người dùng chưa xóa tìm khóa search và bắt đầu
      //chọn tùy chọn mặc định cho filter, bây giờ phải chạy hàm search lại để trả kết quả dựa trên list gốc thay vì filter list
      // if (isSearching) {
      //   searchJobpostings(_searchText);
      //   _filterResultJobposting = [...filteredJobpostings];
      //   return;
      // } else {
      //   _filteredJobpostings = [...jobpostings];
      //   _filterResultJobposting = [...jobpostings];
      // }
      // _filteredJobpostings = [...usedList];
      // _filterResultJobposting = [...usedList];
      // notifyListeners();
    } else {
      isFiltering = true;
      List<Jobposting> tempFilterList = [...usedList];
      //Xử lý nhóm tùy chọn lọc theo thời gian
      if (filterByTime.isNotEmpty) {
        Utils.logMessage('Filter by time');
        final filteredList = tempFilterList.where((jobposting) {
          //Lọc những bài đăng thỏa mãn một trong những điều kiện trong FilterByTime
          final jobpostingCreatedDate = DateTime.parse(jobposting.createdAt);
          final currentDate = DateTime.now();
          final duration = currentDate.difference(jobpostingCreatedDate);
          bool isBelongOneOfTheConditions = false;
          for (var filter in filterByTime) {
            if (filter == FilterByTime.recently24h) {
              final durationInHours = duration.inHours;
              isBelongOneOfTheConditions = durationInHours <= 24;
              break;
            } else if (filter == FilterByTime.recently7days) {
              final durationInDays = duration.inDays;
              isBelongOneOfTheConditions = durationInDays <= 7;
              break;
            } else if (filter == FilterByTime.recently30days) {
              final durationInDays = duration.inDays;
              isBelongOneOfTheConditions = durationInDays <= 30;
              break;
            }
          }
          return isBelongOneOfTheConditions;
        }).toList();

        tempFilterList = [...filteredList];
      } else {
        // tempFilterList = [..._tempJobpostings];
        Utils.logMessage('Empty FilterByTime');
      }
      //Xử lý nhóm tùy chọn lọc theo trạng thái bài đăng
      if (filterByStatus.isNotEmpty) {
        final filteredList = tempFilterList.where((jobposting) {
          final jobpostingDeadline = DateTime.parse(jobposting.deadline);
          final currentDate = DateTime.now();
          bool isSastisfiedCondition = false;
          for (var filterValue in filterByStatus) {
            //Kiểm tra xem bài viết hiện tại có thuộc nhóm active không
            if (filterValue == FilterByJobpostingStatus.active) {
              isSastisfiedCondition = jobpostingDeadline.isAfter(currentDate);
              break;
            } else if (filterValue == FilterByJobpostingStatus.expired) {
              //Kiểm tra bài viết hiện tại có thuộc nhóm expired
              isSastisfiedCondition = jobpostingDeadline.isBefore(currentDate);
              break;
            }
          }
          //Nếu một bài viết thỏa mãn một trong các điều kiện thì trả về
          return isSastisfiedCondition;
        }).toList();
        //Cập nhật lại tempFilterList để ghi nhận thay đổi
        tempFilterList = [...filteredList];
      } else {
        // tempFilterList = [..._tempJobpostings];
        Utils.logMessage('Empty FilterByStatus');
      }
      //Xử lý bộ lọc theo trình độ
      if (filterByLevel.isNotEmpty) {
        //Để lọc theo trình độ thì nếu một bài đăng thỏa mãn 1 điều nào đó trong filterByLevel thì sẽ được hiển thị. Phép lọc
        //này còn gọi là OR
        //Lặp qua từng phần tử và so sánh với mảng filterByLevel
        final filteredList = tempFilterList.where((jobposting) {
          //Lấy danh sách trình độ trong jobposting và chuyển sang chữ thường
          List<String> jobLevel =
              jobposting.level.map((level) => level.toLowerCase()).toList();
          //Lấy danh sách trình độ trong bộ lọc và chuyển sang chữ thường
          List<String> filteredLevel = filterByLevel
              .map((filter) => filter.value.toLowerCase())
              .toList();
          //Dùng hàm any để kiểm tra xem liệu rằng có phần tử nào trong list 1 mà nằm trong list 2 không
          return jobLevel
              .any((levelString) => filteredLevel.contains(levelString));
        }).toList();
        //Gán lại list mới cho tempFilterList
        tempFilterList = [...filteredList];
      } else {
        // tempFilterList = [..._tempJobpostings];
        Utils.logMessage('Empty FilterByLevel');
      }
      //Cuối cùng cập nhật lại _filterJobposting để giao diện cập nhật
      _filteredJobpostings = [...tempFilterList];
      //Gán lại hành động lọc của Filter
      _filterResultJobposting = [...tempFilterList];
      notifyListeners();
    }
  }

  List<Jobposting> _checkFilteredLevelInJobLevel(
      List<Jobposting> list, String filteredLevel) {
    return list.where((jobposting) {
      //Lấy giá trị chuỗi của tùy chọn đã chọn
      final lowerCaseFilterString = filteredLevel.toLowerCase();
      //Chuyển danh sách level sang kiểu chữ thường trước
      final lowerCaseLevelList = jobposting.level
          .map((levelString) => levelString.toLowerCase())
          .toList();
      //So sánh xem giá trị filterString có trong jobpostingLevel không
      return lowerCaseLevelList.contains(lowerCaseFilterString);
    }).toList();
  }

  List<JobpostingListManager> sortJobpostingsByFavoriteCount(
      List<Jobposting> jobposting) {
    return [];
  }
}
