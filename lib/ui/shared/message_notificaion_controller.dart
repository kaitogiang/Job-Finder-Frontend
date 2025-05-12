import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:open_file_manager/open_file_manager.dart';

class MessageNotificaionController {
  static GlobalKey<NavigatorState>?
      navigatorKey; // Declare a static variable for the navigator key

  // Initialize the notification controller with the navigator key
  static void initialize(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
    startListeningNotificationEvents();
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Handle notification based on notification type
    // If it's a message notification, navigate to conversation
    Utils.logMessage(
        'Received action: ${receivedAction.title} ${receivedAction.payload}');
    if (receivedAction.payload?['type'] == 'message_notification') {
      final data = receivedAction.payload;
      // Process the action and handle navigation
      if (navigatorKey?.currentState != null &&
          data?['type'] == 'message_notification') {
        // Navigate to conversation
        final currentContext = navigatorKey?.currentContext;
        Utils.logMessage(
            'context accessed in MessageNotificationController: $currentContext');
        if (currentContext != null && data?['conversationId'] != null) {
          // Navigate to conversation
          GoRouter.of(currentContext).pushNamed(
            "chat",
            extra: data?['conversationId'],
          );
        }
      }
    } else if (receivedAction.payload?['type'] == 'download_notification') {
      // Handle file download notification
      Utils.logMessage('Open folder');
      // Get the path to the directory
      openFileManager(
        androidConfig: AndroidConfig(
          folderType: FolderType.download,
        ),
      );
    } else if (receivedAction.payload?['type'] == 'normal_notification') {
      final target = receivedAction.payload?['target'];
      // If notification target is jobseeker then execute
      if (target == "jobseeker") {
        // Navigate to results list page
        if (navigatorKey?.currentState != null) {
          // Navigate to conversation
          final currentContext = navigatorKey?.currentContext;
          if (currentContext != null) {
            // Navigate to conversation
            GoRouter.of(currentContext).goNamed(
              "saved-work",
            );
          }
        }
      } else if (target == "employer") {
        // Handle notification for employer
        // Navigate to candidates tab
        if (navigatorKey?.currentState != null) {
          // Navigate to conversation
          final currentContext = navigatorKey?.currentContext;
          if (currentContext != null) {
            // Navigate to conversation
            GoRouter.of(currentContext).goNamed(
              "application-list",
            );
          }
        }
      }
    }
  }
}
