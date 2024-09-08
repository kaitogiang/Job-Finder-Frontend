import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:go_router/go_router.dart';

class MessageIcon extends StatelessWidget {
  const MessageIcon({super.key});

  void _gotoConversationList(BuildContext context) {
    context.pushNamed('conversation-list');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      onPressed: () => _gotoConversationList(context),
      backgroundColor: Colors.blueAccent.shade400,
      shape: CircleBorder(),
      child: Badge(
        label: Text('9+'),
        child: Icon(
          Icons.message,
          color: theme.indicatorColor,
        ),
      ),
    );
  }
}
