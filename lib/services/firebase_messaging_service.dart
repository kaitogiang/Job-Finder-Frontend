import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

// Specifically, the FCM background handler must satisfy 3 conditions
// 1. It is not an anonymous function
// 2. It is not located within a class
// 3. It must add @pragma as below
@pragma('vm:entry-point')
Future<void> _messagingBackgroundHandler(RemoteMessage message) async {
  Utils.logMessage('Receive background message: ${message.data}');
  // _createMessageNotification(message);
}

void _createMessageNotification(RemoteMessage message) {
  final data = Map<String, String>.from(message.data);
  final notificationType = data['type'];
  if (notificationType == "message_notification") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecond,
        channelKey: 'message_channel',
        title: message.notification?.title,
        body: message.notification?.body,
        notificationLayout: NotificationLayout.MessagingGroup,
        groupKey: message
            .data['conversationId'], //message_group_key is the first value
        largeIcon: 'asset://assets/images/comments.png',
        payload: data,
      ),
    );
  } else if (notificationType == "normal_notification") {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecond,
        channelKey: 'message_channel',
        title: message.notification?.title,
        body: message.notification?.body,
        notificationLayout: NotificationLayout.MessagingGroup,
        groupKey:
            message.data['jobpostingId'], //message_group_key is the first value
        largeIcon: 'asset://assets/images/total_application.png',
        payload: data,
      ),
    );
  }
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  late String? _registrationToken;

  GlobalKey<NavigatorState>? _globalNavigatorKey;

  set globalNavigatorKey(GlobalKey<NavigatorState> key) {
    _globalNavigatorKey = key;
  }

  String? get registrationToken =>
      _registrationToken; // Setter function to get the registration token of the device

  Future<void> firebaseMessagingInit() async {
    // Request permission and get the device token registered with the FCM backend
    final notificationSettings =
        await _firebaseMessaging.requestPermission(provisional: true);
    final token = await _firebaseMessaging.getToken();
    _registrationToken = token;

    // Check the permission status
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      Utils.logMessage('User granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      Utils.logMessage('User granted provisional permission');
    } else {
      Utils.logMessage('User declined or has not accept');
    }

    // Print out the token information
    if (token != null) {
      Utils.logMessage('Token: $token');
    }
  }

  // Function to handle new notifications in two cases
  // Case 1 is when the application is in the foreground, i.e., displaying the interface
  // Case 2 is running in the background and the user clicks on the notification, it will execute
  void _handleInteraction(RemoteMessage message) {
    Utils.logMessage(
        'Receive new notifcation, title: ${message.notification?.title}, body: ${message.notification?.body}');
    Utils.logMessage('Optional data in notification: ${message.data}');
    // Handle navigation to a specific conversation
    // First, check if the notification type is a message notification (message_notification)
    final data = message.data;
    if (data['type'] == 'message_notification') {
      // Handle navigation to the default conversation
    }
  }

  void _navigateToConversation(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'message_notification') {
      // Navigate to the conversation
      final currentContext = _globalNavigatorKey?.currentContext;
      Utils.logMessage(
          'context accessed in FirebaseMessagingServer: $currentContext');
      if (currentContext != null) {
        // Navigate to the conversation
        GoRouter.of(currentContext).pushNamed(
          "chat",
          extra: data['conversationId'],
        );
      }
    }
  }

  Future<void> setUpInteractedMessage() async {
    //----- Handle notifications when in terminated state
    // Get the message when the application is in terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    // If there is a notification received when the application is in terminated state, handle it
    if (initialMessage != null) {
      _handleInteraction(initialMessage);
    }
    //----- Handle notifications when the application is in the background and the user
    // clicks on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleInteraction(message);
      _navigateToConversation(message);
    });

    // Handle when receiving notifications when the application is running in the foreground
    FirebaseMessaging.onMessage.listen((message) {
      _handleInteraction(message);
      _createMessageNotification(message);
    });

    // Handle when receiving notifications when the application is running in the background
    FirebaseMessaging.onBackgroundMessage(_messagingBackgroundHandler);
  }
}
