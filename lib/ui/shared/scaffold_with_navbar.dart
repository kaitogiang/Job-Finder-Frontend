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
        onTap: (index) => navigationShell.goBranch(index),
        items: isEmployer
          ? _buildEmployerNavItems() : _buildEmployeeNavItems(),
      ),
    );
  }

  //Hàm build các mục cho người tìm việc
  List<BottomNavigationBarItem> _buildEmployeeNavItems() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Trang chủ'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Tìm kiếm'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home_repair_service),
        label: 'Công việc'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business),
        label: 'Công ty'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Tài khoản'
      ),
    ];
  }

  //Hàm build các mục cho nhà tuyển dụng
  List<BottomNavigationBarItem> _buildEmployerNavItems() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Bài đăng'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Ứng viên'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home_repair_service),
        label: 'Đã duyệt'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.business),
        label: 'Công ty'
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Tài khoản'
      ),
    ];
  }
}