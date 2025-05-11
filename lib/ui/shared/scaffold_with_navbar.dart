import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/shared/message_manager.dart';
import 'package:provider/provider.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
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

  //Function to navigate to a branch
  void _onTap(BuildContext context, int index) {
    //The goBranch function is used to navigate to a defined branch
    //by index. Branch order starts from 0. First branch is 0,
    //second is 1, etc.
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
  }

  //Function to build navigation items for job seekers
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

  //Function to build navigation items for employers
  List<BottomNavigationBarItem> _buildEmployerNavItems() {
    return <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bài đăng'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person_add_alt_rounded), label: 'Ứng viên'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.business), label: 'Công ty'),
      BottomNavigationBarItem(
          icon: Selector<MessageManager, int>(
              selector: (context, messageManager) =>
                  messageManager.unseenEmployerMessages,
              builder: (context, unseenEmployerMessages, child) {
                return unseenEmployerMessages > 0
                    ? Badge(
                        label: Text(unseenEmployerMessages > 9
                            ? '9+'
                            : unseenEmployerMessages.toString()),
                        child: Icon(
                          Icons.message,
                          // color: theme.indicatorColor,
                        ),
                      )
                    : Icon(Icons.chat_sharp);
              }),
          label: 'Tin nhắn'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person), label: 'Tài khoản'),
    ];
  }
}
