import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_manager.dart';

class JobseekerHome extends StatelessWidget {

  const JobseekerHome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobseeker Home'),
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
        child: Text('Employee Home ${context.read<AuthManager>().jobseeker.skills}'),
      ),
    );
  }
}