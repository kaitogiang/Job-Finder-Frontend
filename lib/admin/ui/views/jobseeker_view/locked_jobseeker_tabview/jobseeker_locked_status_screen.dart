import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/locked_users.dart';

class JobseekerLockedStatusScreen extends StatelessWidget {
  const JobseekerLockedStatusScreen(
      {super.key, required this.lockedInfoFuture});

  final Future<LockedUser?> lockedInfoFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);

    return FutureBuilder(
        future: lockedInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                width: 420,
                child: const Center(child: CircularProgressIndicator()));
          }
          final lockedUser = snapshot.data!;
          String formattedLockedAt =
              DateFormat('dd-MM-yyyy HH:mm:ss').format(lockedUser.lockedAt);
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ngày khóa', style: basicInfoTitle),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 1,
                  minLines: 1,
                  readOnly: true,
                  initialValue: formattedLockedAt,
                ),
                const SizedBox(height: 10),
                Text('Lý do khóa', style: basicInfoTitle),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
                  minLines: 5,
                  readOnly: true,
                  initialValue: lockedUser.reason,
                )
              ],
            ),
          );
        });
  }
}
