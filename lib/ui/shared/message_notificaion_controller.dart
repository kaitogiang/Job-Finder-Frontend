import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

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
    final data = receivedAction.payload;
    // Process the action and handle navigation
    if (navigatorKey?.currentState != null &&
        data?['type'] == 'message_notification') {
      //Chuyển hướng đến conversation
      final currentContext = navigatorKey?.currentContext;
      Utils.logMessage(
          'context truy cap trong MessageNotificationController: $currentContext');
      if (currentContext != null && data?['conversationId'] != null) {
        //Chuyển hướng đến conversation
        GoRouter.of(currentContext).pushNamed(
          "chat",
          extra: data?['conversationId'],
        );
      }
    }
  }
}
