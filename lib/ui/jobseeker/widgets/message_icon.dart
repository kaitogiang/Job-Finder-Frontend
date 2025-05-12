import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/shared/message_manager.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MessageIcon extends StatelessWidget {
  const MessageIcon({Key? key}) : super(key: key);

  void _gotoConversationList(BuildContext context) {
    context.pushNamed('conversation-list');
  }

  @override
  Widget build(BuildContext context) {
    Utils.logMessage('MessageIcon build');
    final theme = Theme.of(context);
    final isEmployer = context.read<AuthManager>().isEmployer;
    final messageManager = context.read<MessageManager>();
    final unseenMessages = isEmployer
        ? messageManager.unseenEmployerMessages
        : messageManager.unseenJobseekerMessages;

    return FloatingActionButton(
      onPressed: () => _gotoConversationList(context),
      backgroundColor: Colors.blueAccent.shade400,
      shape: CircleBorder(),
      child: unseenMessages > 0
          ? Badge(
              label: Text(
                  unseenMessages > 9 ? '9+' : unseenMessages.toString()),
              child: Icon(
                Icons.message,
                color: theme.indicatorColor,
              ),
            )
          : Icon(
              Icons.message,
              color: theme.indicatorColor,
            ),
    );
  }
}
