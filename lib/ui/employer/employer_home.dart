import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_manager.dart';

class EmployerHome extends StatelessWidget {
  const EmployerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employer Home'),
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
        child: Text('Employer Home'),
      ),
    );
  }
}