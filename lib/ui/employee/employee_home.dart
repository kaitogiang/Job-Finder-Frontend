import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_manager.dart';

class EmployeeHome extends StatelessWidget {

  const EmployeeHome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthManager>().logout();
            },
          )
        ],
      ),
      body: Center(
        child: Text('Employee Home ${context.read<AuthManager>().employee.skills}'),
      ),
    );
  }
}