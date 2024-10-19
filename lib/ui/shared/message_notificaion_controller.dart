// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class NotificationController {
//   static GlobalKey<NavigatorState>?
//       navigatorKey; // Declare a static variable for the navigator key

//   // Initialize the notification controller with the navigator key
//   static void initialize(GlobalKey<NavigatorState> key) {
//     navigatorKey = key;
//     startListeningNotificationEvents();
//   }

//   static Future<void> startListeningNotificationEvents() async {
//     AwesomeNotifications()
//         .setListeners(onActionReceivedMethod: onActionReceivedMethod);
//   }

//   @pragma('vm:entry-point')
//   static Future<void> onActionReceivedMethod(
//       ReceivedAction receivedAction) async {
//     // Process the action and handle navigation
//     if (navigatorKey?.currentState != null) {
      
//     }
//   }
// }
