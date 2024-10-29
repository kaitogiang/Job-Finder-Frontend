import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/manager/admin_auth_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/widgets/navigation_item.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class BaseLayoutPage extends StatefulWidget {
  const BaseLayoutPage({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  State<BaseLayoutPage> createState() => _BaseLayoutPageState();
}

class _BaseLayoutPageState extends State<BaseLayoutPage> {
  //Biến lưu trữ chỉ số trang đang chọn hiện tại để biết mà khởi tạo active state.
  final ValueNotifier<int> _currentPageIndex = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    //Thêm listener để lắng nghe sự thay đổi của route hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String currentPath = GoRouterState.of(context).fullPath!;
      Utils.logMessage('currentPath: $currentPath');
      _currentPageIndex.value = _extractPageIndexFromPath(currentPath);
    });
  }

  //hàm trích xuất url để nhận biết hiện tại trang đang ở đường dẫn nào để biết mà
  //bật active state cho navigation item tương ứng
  int _extractPageIndexFromPath(String path) {
    switch (path) {
      case '/':
        return 0;
      case '/jobseeker':
        return 1;
      case '/employer':
        return 2;
      case '/jobposting':
        return 3;
      case '/application':
        return 4;
      case '/notification':
        return 5;
      case '/feedback':
        return 6;
      default:
        return 0;
    }
  }

  void _changePageIndex(int index) {
    _currentPageIndex.value = index;
  }

  Future<void> _logout() async {
    if (mounted) {
      await context.read<AdminAuthManager>().logout();
      //Hiển thị thông báo
      if (mounted) {
        Utils.showNotification(
          context: context,
          title: 'Đăng xuất thành công',
          type: ToastificationType.success,
        );
      }
    }
  }

  void _onTap(BuildContext context, int index) {
    Router.neglect(
        context, () => widget.child.goBranch(index, initialLocation: true));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final adminName = context.read<AdminAuthManager>().name;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // context.go('/');
                  // Router.neglect(
                  //   context,
                  //   () => context.go('/'),
                  // );
                  _onTap(context, 0);
                  _changePageIndex(0);
                },
                child: CircleAvatar(
                  child: Image.asset("assets/images/job_logo.png"),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  context.go('/');
                  _changePageIndex(0);
                },
                child: Text(
                  'Job Finder Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            tooltip: 'Hiển thị thông báo',
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'item1',
                child: Column(
                  children: [
                    Text('Có ứng viên vừa trúng tuyển thành công'),
                    Text('Có người gian lận'),
                    Text('Có người gian lận'),
                    Text('Xử lý trường hợp gian lận'),
                  ],
                ),
              ),
            ],
            child: Badge(
              label: Text('10'),
              child: Icon(Icons.notifications),
            ),
          ),
          const SizedBox(width: 15.0),
          Stack(
            children: [
              CircleAvatar(
                child: Image.asset("assets/images/job_logo.png"),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Utils.logMessage('Try cap vao avatar');
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15.0),
          Text(
            adminName,
            style: textTheme.titleSmall,
          ),
          const SizedBox(width: 10.0),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Container(
            color: Colors.grey[100],
            height: 10,
          ),
        ),
      ),
      body: Container(
        height: screenSize.height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: <Widget>[
            //Phần điều hướng
            SizedBox(
              width: 280,
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: ValueListenableBuilder(
                      valueListenable: _currentPageIndex,
                      builder: (context, value, child) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Dashboard
                              NavigationItem(
                                title: 'Bảng điều khiển',
                                icon: Icons.dashboard,
                                onPressed: () {
                                  Utils.logMessage('Bảng điều khiển');
                                  // context.go('/');
                                  // Router.neglect(
                                  //   context,
                                  //   () => context.go('/'),
                                  // );

                                  _changePageIndex(0);
                                },
                                isActive: _currentPageIndex.value == 0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 10.0),
                                child: Text(
                                  'Quản lý người dùng',
                                  style: textTheme.titleMedium,
                                ),
                              ),
                              //Quản lý ứng viên
                              NavigationItem(
                                title: 'Quản lý ứng viên',
                                icon: Icons.person,
                                onPressed: () {
                                  Utils.logMessage('Quản lý ứng viên');
                                  // context.go('/jobseeker');
                                  // Router.neglect(
                                  //   context,
                                  //   () => context.go('/jobseeker'),
                                  // );
                                  _onTap(context, 1);
                                  _changePageIndex(1);
                                },
                                isActive: _currentPageIndex.value == 1,
                              ),
                              const SizedBox(height: 4.0),
                              //Quản lý nhà tuyển dụng
                              NavigationItem(
                                title: 'Quản lý nhà tuyển dụng',
                                icon: Icons.business,
                                onPressed: () {
                                  Utils.logMessage('Quản lý nhà tuyển dụng');
                                  _changePageIndex(2);
                                  // context.go('/employer');
                                  // Router.neglect(
                                  //   context,
                                  //   () => context.go('/employer'),
                                  // );
                                  _onTap(context, 2);
                                },
                                isActive: _currentPageIndex.value == 2,
                              ),
                              //Công việc & hồ sơ
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 10.0),
                                child: Text(
                                  'Công việc & hồ sơ',
                                  style: textTheme.titleMedium,
                                ),
                              ),
                              //Quản lý bài tuyển dụng
                              NavigationItem(
                                title: 'Quản lý bài tuyển dụng',
                                icon: Icons.comment,
                                onPressed: () {
                                  Utils.logMessage('Quản lý bài tuyển dụng');
                                  _changePageIndex(3);
                                  // context.go('/jobposting');
                                  // Router.neglect(
                                  //   context,
                                  //   () => context.go('/jobposting'),
                                  // );
                                  _onTap(context, 3);
                                },
                                isActive: _currentPageIndex.value == 3,
                              ),
                              const SizedBox(height: 4.0),
                              //Quản lý hồ sơ ứng tuyển
                              NavigationItem(
                                title: 'Quản lý hồ sơ ứng tuyển',
                                icon: Icons.card_travel_sharp,
                                onPressed: () {
                                  Utils.logMessage('Quản lý hồ sơ ứng tuyển');
                                  _changePageIndex(4);
                                  // context.go('/application');
                                  // Router.neglect(
                                  //   context,
                                  //   () => context.go('/application'),
                                  // );
                                  _onTap(context, 4);
                                },
                                isActive: _currentPageIndex.value == 4,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 10.0),
                                child: Text(
                                  'Thông báo và phản hồi',
                                  style: textTheme.titleMedium,
                                ),
                              ),
                              //Quản lý thông báo
                              NavigationItem(
                                title: 'Quản lý thông báo',
                                icon: Icons.notifications,
                                onPressed: () {
                                  Utils.logMessage('Quản lý thông báo');
                                  _changePageIndex(5);
                                  // context.go('/notification');
                                  // Router.neglect(
                                  //   context,
                                  //   () => context.go('/notification'),
                                  // );
                                  _onTap(context, 5);
                                },
                                isActive: _currentPageIndex.value == 5,
                              ),
                              const SizedBox(height: 4.0),
                              //Quản lý phản hồi
                              NavigationItem(
                                title: 'Quản lý phản hồi',
                                icon: Icons.feedback,
                                onPressed: () {
                                  Utils.logMessage('Quản lý phản hồi');
                                  _changePageIndex(6);
                                  // context.go('/feedback');
                                  // Router.neglect(
                                  //   context,
                                  //   () => context.go('/feedback'),
                                  // );
                                  _onTap(context, 6);
                                },
                                isActive: _currentPageIndex.value == 6,
                              ),
                              //Nếu parent của Divider không đặt width thì Divider sẽ không hiển thị được
                              //bởi vì nó không biết chiều rộng của nó là bao nhiêu
                              Divider(
                                color: Colors.grey,
                                thickness: 1,
                                height: 20,
                              ),
                              // NavigationItem(
                              //   title: 'Thông tin cá nhân',
                              //   icon: Icons.admin_panel_settings,
                              //   onPressed: () {
                              //     Utils.logMessage(
                              //         'Truy cap thong tin ca nhan');
                              //   },
                              //   isActive: false,
                              // ),
                              // const SizedBox(height: 10.0),
                              NavigationItem(
                                title: 'Đăng xuất',
                                icon: Icons.logout,
                                onPressed: _logout,
                                isActive: false,
                              ),
                              const SizedBox(height: 80.0),
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ),
            //phần nội dung chính, thay đổi theo mỗi trang
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                width: screenSize.width,
                height: screenSize.height,
                child: widget.child,
              ),
            )
          ],
        ),
      ),
    );
  }
}
