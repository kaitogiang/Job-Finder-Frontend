import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:provider/provider.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final authManager = context.read<AuthManager>();
    final isEmployer = authManager.isEmployer;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        items:
            isEmployer ? _buildEmployerNavItems() : _buildJobseekerNavItems(),
      ),
    );
  }

  //Hàm dùng để chuyển hướng tới một nhánh
  void _onTap(BuildContext context, int index) {
    //Hàm goBranch dùng để chuyển hướng tới một nhánh nào đó đã định nghĩa
    //theo chỉ số. Thứ tự các nhánh bắt đầu từ 0. Nhánh đầu tiên là 0,
    //thứ hai là 1, vv..vv
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
  }

  //Hàm build các mục cho người tìm việc
  List<BottomNavigationBarItem> _buildJobseekerNavItems() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
      BottomNavigationBarItem(
          icon: Icon(Icons.home_repair_service), label: 'Công việc'),
      BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Công ty'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
    ];
  }

  //Hàm build các mục cho nhà tuyển dụng
  List<BottomNavigationBarItem> _buildEmployerNavItems() {
    return <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bài đăng'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person_add_alt_rounded), label: 'Ứng viên'),
      // const BottomNavigationBarItem(
      //     icon: Icon(Icons.home_repair_service), label: 'Đã duyệt'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.business), label: 'Công ty'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Tài khoản'),
    ];
  }
}
