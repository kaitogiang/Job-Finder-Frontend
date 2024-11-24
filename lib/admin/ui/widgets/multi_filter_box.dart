import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/jobposting_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:provider/provider.dart';

class MultiFilterBox extends StatefulWidget {
  const MultiFilterBox(
      {super.key,
      required this.filterByTimeSelection,
      required this.filterByStatusSelection,
      required this.filterByLevelSelection});

  final ValueNotifier<List<FilterByTime>> filterByTimeSelection;
  final ValueNotifier<List<FilterByJobpostingStatus>> filterByStatusSelection;
  final ValueNotifier<List<FilterByJobLevel>> filterByLevelSelection;

  @override
  State<MultiFilterBox> createState() => _MultiFilterBoxState();
}

class _MultiFilterBoxState extends State<MultiFilterBox> {
  final _scrollController = ScrollController();

  //Mảng dùng để lưu trữ giá trị lọc hiện tại mà admin đã chọn
  final ValueNotifier<List<FilterByTime>> _currentFilterByTimeSelection =
      ValueNotifier([]);
  final ValueNotifier<List<FilterByJobpostingStatus>>
      _currentFilterByStatusSelection = ValueNotifier([]);
  final ValueNotifier<List<FilterByJobLevel>> _currentFilterByLevelSelection =
      ValueNotifier([]);

  final ValueNotifier<bool> _isShowAll = ValueNotifier(true);

  //Những danh sách dùng để khôi phục lại tùy chọn trước đó nếu người dùng không
  //lưu, tại vì khi chọn thì trạng nó sẽ được giữ lại do MenuAnchor chỉ nạp một
  //lần và lưu giữ trạng thái, nên cần phải tạo một bản sao ban đầu cho nó
  List<FilterByTime> _originalFilterByTime = [];
  List<FilterByJobpostingStatus> _originalFilterByStatus = [];
  List<FilterByJobLevel> _originalFilterByLevel = [];

  @override
  void initState() {
    super.initState();
    final filterByTime = widget.filterByTimeSelection.value;
    final filterByStatus = widget.filterByStatusSelection.value;
    final filterByLevel = widget.filterByLevelSelection.value;

    _isShowAll.value =
        filterByTime.isEmpty && filterByStatus.isEmpty && filterByLevel.isEmpty;

    //Khởi tạo giá trị cho các list tạm để khôi phục giá trị
    _originalFilterByTime = [...filterByTime];
    _originalFilterByStatus = [...filterByStatus];
    _originalFilterByLevel = [...filterByLevel];
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    Utils.logMessage('Dispose multi_filter');
  }

  //Hàm kiểm tra xem 3 list current bên trong có rỗng không để quyết định
  //Chọn tùy chọn "Tất cả" ở trên cùng
  void _checkShowAllOptionLocal() {
    _isShowAll.value = _currentFilterByTimeSelection.value.isEmpty &&
        _currentFilterByStatusSelection.value.isEmpty &&
        _currentFilterByLevelSelection.value.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final menuButtonStyle = MenuItemButton.styleFrom(
      padding: EdgeInsets.zero,
      overlayColor: Colors.transparent,
      disabledBackgroundColor: Colors.white,
      disabledForegroundColor: Colors.black,
    );
    MenuController controller = MenuController();

    //Khởi tạo các giá trị
    //Khởi tạo các tùy chọn ban đầu
    _currentFilterByTimeSelection.value
        .addAll(widget.filterByTimeSelection.value);
    _currentFilterByStatusSelection.value
        .addAll(widget.filterByStatusSelection.value);
    _currentFilterByLevelSelection.value
        .addAll(widget.filterByLevelSelection.value);

    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final basicInfoTitle = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black54,
      fontSize: 15,
    );
    final basicValueStyle = theme.textTheme.bodyMedium!.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
    final titleCardStyle = textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return MenuAnchor(
      controller: controller,
      onClose: () {
        // //Lấy giá trị của ValueNotifer để so sánh
        // final filterByTime = widget.filterByTimeSelection.value;
        // final filterByStatus = widget.filterByStatusSelection.value;
        // final filterByLevel = widget.filterByLevelSelection.value;
        // if (filterByTime.isEmpty) {
        //   //Đặt lại các giá trị chọn hiện tại bởi vì người dùng chưa lưu lại
        //   _currentFilterByTimeSelection.value.clear();
        //   //Kiểm tra xem cả hai list có rỗng không để quyết định tích chọn "Tất cả"
        //   _isShowAll.value = filterByTime.isEmpty &&
        //       filterByStatus.isEmpty &&
        //       filterByLevel.isEmpty;
        // }
        // if (filterByStatus.isEmpty) {
        //   _currentFilterByStatusSelection.value.clear();
        //   //Kiểm tra xem cả hai list có rỗng không để quyết định tích chọn "Tất cả"
        //   _isShowAll.value = filterByTime.isEmpty &&
        //       filterByStatus.isEmpty &&
        //       filterByLevel.isEmpty;
        // }
        // if (filterByLevel.isEmpty) {
        //   _currentFilterByLevelSelection.value.clear();
        //   //Kiểm tra xem cả hai list có rỗng không để quyết định tích chọn "Tất cả"
        //   _isShowAll.value = filterByTime.isEmpty &&
        //       filterByStatus.isEmpty &&
        //       filterByLevel.isEmpty;
        // }

        //Khôi phục lại giá trị cho các list current nếu người dùng chọn nhưng không lưu
        //Lấy giá trị của ValueNotifer để so sánh

        _currentFilterByTimeSelection.value = [..._originalFilterByTime];
        _currentFilterByStatusSelection.value = [..._originalFilterByStatus];
        _currentFilterByLevelSelection.value = [..._originalFilterByLevel];

        final filterByTime = _currentFilterByTimeSelection.value;
        final filterByStatus = _currentFilterByStatusSelection.value;
        final filterByLevel = _currentFilterByLevelSelection.value;
        _isShowAll.value = filterByTime.isEmpty &&
            filterByStatus.isEmpty &&
            filterByLevel.isEmpty;

        // if (filterByTime.isEmpty) {
        //   //Đặt lại các giá trị chọn hiện tại bởi vì người dùng chưa lưu lại
        //   _currentFilterByTimeSelection.value.clear();
        //   //Kiểm tra xem cả hai list có rỗng không để quyết định tích chọn "Tất cả"
        //   _isShowAll.value = filterByTime.isEmpty &&
        //       filterByStatus.isEmpty &&
        //       filterByLevel.isEmpty;
        // }
        // if (filterByStatus.isEmpty) {
        //   _currentFilterByStatusSelection.value.clear();
        //   //Kiểm tra xem cả hai list có rỗng không để quyết định tích chọn "Tất cả"
        //   _isShowAll.value = filterByTime.isEmpty &&
        //       filterByStatus.isEmpty &&
        //       filterByLevel.isEmpty;
        // }
        // if (filterByLevel.isEmpty) {
        //   _currentFilterByLevelSelection.value.clear();
        //   //Kiểm tra xem cả hai list có rỗng không để quyết định tích chọn "Tất cả"
        //   _isShowAll.value = filterByTime.isEmpty &&
        //       filterByStatus.isEmpty &&
        //       filterByLevel.isEmpty;
        // }
      },
      menuChildren: [
        MenuItemButton(
          style: menuButtonStyle,
          closeOnActivate: false,
          requestFocusOnHover: false,
          child: Container(
            width: 250,
            height: 460,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Hiển thị tiêu đề của filter box
                Text(
                  'Lọc bài tuyển dụng',
                  style: titleCardStyle,
                ),
                //Hiển thị các tiêu đề và các tùy chọn lọc
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Tùy chọn mặc định, hiển thị tất cả không lọc
                          ListTile(
                            leading: ValueListenableBuilder(
                                valueListenable: _isShowAll,
                                builder: (context, isShowAll, child) {
                                  return Checkbox(
                                    value: isShowAll,
                                    onChanged: (value) {
                                      _currentFilterByTimeSelection.value = [];
                                      _currentFilterByStatusSelection.value =
                                          [];
                                      _currentFilterByLevelSelection.value = [];
                                      _isShowAll.value =
                                          _currentFilterByTimeSelection
                                                  .value.isEmpty &&
                                              _currentFilterByStatusSelection
                                                  .value.isEmpty &&
                                              _currentFilterByLevelSelection
                                                  .value.isEmpty;
                                    },
                                  );
                                }),
                            title: Text(
                              'Tất cả',
                              style: basicValueStyle,
                            ),
                          ),
                          //Lọc theo thời gian, 24h qua, 7 ngày qua, 30 ngày qua
                          Text(
                            'Theo thời gian',
                            style: basicInfoTitle,
                          ),
                          //Dùng StatefulBuilder để chỉ rebuil lại các option này khi cần thiết
                          ValueListenableBuilder(
                              valueListenable: _currentFilterByTimeSelection,
                              builder: (context, currentFilterByTimeSelection,
                                  child) {
                                return Column(
                                  children: List<Widget>.generate(
                                      FilterByTime.values.length, (index) {
                                    //Lưu trữ lại option tại index cụ thể trong enum
                                    final currentOptionValue =
                                        FilterByTime.values.elementAt(index);
                                    return ListTile(
                                      leading: Checkbox(
                                        value: index == 0 &&
                                                currentFilterByTimeSelection
                                                    .isEmpty ||
                                            currentFilterByTimeSelection
                                                .contains(currentOptionValue),
                                        onChanged: (value) {
                                          //Thay đổi danh sách tùy chọn lọc đã chọn, ban đầu là rỗng, do
                                          //chưa chọn option lọc nào
                                          //Lữu trữ vào danh sách tạm, khi nào mà người dùng nhấn áp dụng thì mới thay đỏi giá trị
                                          //của ValueNotifer đã truyền vào lớp
                                          //Nếu option hiện tại được chọn
                                          //Số lượng tùy chọn đã chọn trong loại option này
                                          int numberOfOption =
                                              FilterByTime.values.length - 1;
                                          //Khi người dùng đã chọn các tùy chọn khác nhưng sau đó chọn lại
                                          //cái mặc định thì những cái khác tự động bỏ chọn
                                          if (index == 0 &&
                                              currentFilterByTimeSelection
                                                  .isNotEmpty &&
                                              value == true) {
                                            currentFilterByTimeSelection
                                                .clear();
                                            _currentFilterByTimeSelection
                                                .value = [
                                              ...currentFilterByTimeSelection
                                            ];
                                            _checkShowAllOptionLocal();
                                            //Nếu người dùng chọn tùy chọn cuối cùng và số lượng hiện giờ bằng với số lượng tùy chọn đã định nghĩa trừ cái mặc định,
                                            //thì đưa về mặc định, tương đương với tùy chọn "Tất cả".
                                            //Khi người dùng chọn tùy chọn cuối cùng, mặc dù nó true, nhưng giá trị chọn
                                            //chưa thêm vào danh sách chọn, nên điều kiện so sánh bằng bị sai. Do đó,
                                            //Phải cộng 1 vào cho _currentFilterByTimeSelection.length để đại diện cho
                                            //Phần tử sẽ sắp thêm vào
                                          } else if (value == true &&
                                              currentFilterByTimeSelection
                                                          .length +
                                                      1 ==
                                                  numberOfOption) {
                                            Utils.logMessage(
                                                'Thêm phần tử cuối');
                                            currentFilterByTimeSelection
                                                .clear();
                                            _currentFilterByTimeSelection
                                                .value = [
                                              ...currentFilterByTimeSelection
                                            ];
                                            _checkShowAllOptionLocal();
                                          } else if (value == true) {
                                            currentFilterByTimeSelection
                                                .add(currentOptionValue);
                                            _currentFilterByTimeSelection
                                                .value = [
                                              ...currentFilterByTimeSelection
                                            ];
                                            _checkShowAllOptionLocal();
                                          } else {
                                            //Nếu option hiện tại không được chọn
                                            currentFilterByTimeSelection
                                                .remove(currentOptionValue);
                                            _currentFilterByTimeSelection
                                                .value = [
                                              ...currentFilterByTimeSelection
                                            ];
                                            _checkShowAllOptionLocal();
                                          }
                                        },
                                      ),
                                      title: Text(
                                        currentOptionValue.value,
                                        style: basicValueStyle,
                                      ),
                                    );
                                  }),
                                );
                              }),
                          //Lọc theo trạng thái bài đăng: tất cả, còn hạn, hết hạn
                          Text(
                            'Theo trạng thái bài đăng',
                            style: basicInfoTitle,
                          ),
                          ValueListenableBuilder(
                            valueListenable: _currentFilterByStatusSelection,
                            builder: (context, currentFilterByStatusSelection,
                                child) {
                              return Column(
                                children: List<ListTile>.generate(
                                    FilterByJobpostingStatus.values.length,
                                    (index) {
                                  //Lưu trữ lại giá trị đang chọn
                                  final currentOptionValue =
                                      FilterByJobpostingStatus.values
                                          .elementAt(index);
                                  return ListTile(
                                    leading: Checkbox(
                                      value: index == 0 &&
                                              currentFilterByStatusSelection
                                                  .isEmpty ||
                                          currentFilterByStatusSelection
                                              .contains(currentOptionValue),
                                      onChanged: (value) {
                                        int numberOfOptions =
                                            FilterByJobpostingStatus
                                                    .values.length -
                                                1;
                                        if (index == 0 &&
                                            currentFilterByStatusSelection
                                                .isNotEmpty &&
                                            value == true) {
                                          currentFilterByStatusSelection
                                              .clear();
                                          _currentFilterByStatusSelection
                                              .value = [
                                            ...currentFilterByStatusSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        } else if (value == true &&
                                            currentFilterByStatusSelection
                                                        .length +
                                                    1 ==
                                                numberOfOptions) {
                                          currentFilterByStatusSelection
                                              .clear();
                                          _currentFilterByStatusSelection
                                              .value = [
                                            ...currentFilterByStatusSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        } else if (value == true) {
                                          currentFilterByStatusSelection
                                              .add(currentOptionValue);
                                          _currentFilterByStatusSelection
                                              .value = [
                                            ...currentFilterByStatusSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        } else {
                                          currentFilterByStatusSelection
                                              .remove(currentOptionValue);
                                          _currentFilterByStatusSelection
                                              .value = [
                                            ...currentFilterByStatusSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        }
                                      },
                                    ),
                                    title: Text(
                                      FilterByJobpostingStatus.values
                                          .elementAt(index)
                                          .value,
                                      style: basicValueStyle,
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                          //Lọc theo loại công việc
                          Text(
                            'Theo trình độ',
                            style: basicInfoTitle,
                          ),
                          ValueListenableBuilder(
                            valueListenable: _currentFilterByLevelSelection,
                            builder: (context, currentFilterByLevelSelection,
                                child) {
                              return Column(
                                children: List<ListTile>.generate(
                                    FilterByJobLevel.values.length, (index) {
                                  final currentOptionValue =
                                      FilterByJobLevel.values.elementAt(index);
                                  return ListTile(
                                    leading: Checkbox(
                                      value: index == 0 &&
                                              currentFilterByLevelSelection
                                                  .isEmpty ||
                                          currentFilterByLevelSelection
                                              .contains(currentOptionValue),
                                      onChanged: (value) {
                                        int numberOfOptions =
                                            FilterByJobLevel.values.length - 1;
                                        if (index == 0 &&
                                            currentFilterByLevelSelection
                                                .isNotEmpty &&
                                            value == true) {
                                          currentFilterByLevelSelection.clear();
                                          _currentFilterByLevelSelection.value =
                                              [
                                            ...currentFilterByLevelSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        } else if (value == true &&
                                            currentFilterByLevelSelection
                                                        .length +
                                                    1 ==
                                                numberOfOptions) {
                                          currentFilterByLevelSelection.clear();
                                          _currentFilterByLevelSelection.value =
                                              [
                                            ...currentFilterByLevelSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        } else if (value == true) {
                                          currentFilterByLevelSelection
                                              .add(currentOptionValue);
                                          _currentFilterByLevelSelection.value =
                                              [
                                            ...currentFilterByLevelSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        } else {
                                          currentFilterByLevelSelection
                                              .remove(currentOptionValue);
                                          _currentFilterByLevelSelection.value =
                                              [
                                            ...currentFilterByLevelSelection
                                          ];
                                          _checkShowAllOptionLocal();
                                        }
                                      },
                                    ),
                                    title: Text(
                                      FilterByJobLevel.values
                                          .elementAt(index)
                                          .value,
                                      style: basicValueStyle,
                                    ),
                                  );
                                }),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          closeOnActivate: false,
          child: TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(),
              padding: EdgeInsets.symmetric(
                vertical: 10,
              ),
            ),
            onPressed: () {
              //Cập nhật lại các ValueNotifier đã truyền vào
              widget.filterByTimeSelection.value = [
                ..._currentFilterByTimeSelection.value
              ];
              widget.filterByStatusSelection.value = [
                ..._currentFilterByStatusSelection.value
              ];
              widget.filterByLevelSelection.value = [
                ..._currentFilterByLevelSelection.value
              ];

              //Lưu lại trạng thái cho các danh sách original
              _originalFilterByTime = [..._currentFilterByTimeSelection.value];
              _originalFilterByStatus = [
                ..._currentFilterByStatusSelection.value
              ];
              _originalFilterByLevel = [
                ..._currentFilterByLevelSelection.value
              ];
              //Gọi hàm cập nhật các điều kiện lọc lại
              context.read<JobpostingListManager>().updateFilterValue(
                    filterByTimeList: widget.filterByTimeSelection.value,
                    filterByStatusList: widget.filterByStatusSelection.value,
                    filterByLevelList: widget.filterByLevelSelection.value,
                  );
              //Gọi hàm cập nhật lại giao diện theo tiêu chí lọc
              // context.read<JobpostingListManager>().filterJobposting(
              //     widget.filterByTimeSelection.value,
              //     widget.filterByStatusSelection.value,
              //     widget.filterByLevelSelection.value);
              context.read<JobpostingListManager>().filterJobposting(
                    widget.filterByTimeSelection.value,
                    widget.filterByStatusSelection.value,
                    widget.filterByLevelSelection.value,
                  );
              Utils.logMessage('Thuc hien filter');
              controller.close();
            },
            child: Text('Áp dụng'),
          ),
        )
      ],
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 7,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(color: Colors.grey.shade600)),
          fixedSize: Size(160, 38),
        ),
        icon: Icon(
          Icons.sort,
          color: Colors.grey.shade600,
        ),
        label: Text(
          'Lọc bài đăng',
          style: textTheme.bodyMedium!.copyWith(color: Colors.grey.shade600),
        ),
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
    );
  }
}
