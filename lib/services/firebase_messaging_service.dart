import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

//Riêng xử lý chạy background của FCM background thì phải thỏa mãn 3 điều kiện
//1. Không là hàm ẩn danh
//2. Không nằm trong lớp
//3. Phải thêm @pragma như bên dưới
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
      _registrationToken; //Hàm setter lấy registration token của thiết bị

  Future<void> firebaseMessagingInit() async {
    //Yêu cầu quyền và lấy token của thiết bị đã đăng ký với FCM backend
    final notificationSettings =
        await _firebaseMessaging.requestPermission(provisional: true);
    final token = await _firebaseMessaging.getToken();
    _registrationToken = token;

    //Kiểm tra xem quyền hạn thế nào
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      Utils.logMessage('User granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      Utils.logMessage('User granted provisional permission');
    } else {
      Utils.logMessage('User declined or has not accept');
    }

    //In ra thông tin của token
    if (token != null) {
      Utils.logMessage('Token: $token');
    }
  }

  //Hàm dùng để xử lý thông báo mới đến trong hai trường hợp
  //Trường hợp 1 là khi ứng dụng đang ở trạng thái foreground tức là đang hiển thị giao diện
  //Trường hợp 2 là đang chạy nền và người dùng bấm vào thông báo thì nó sẽ thực thi
  void _handleInteraction(RemoteMessage message) {
    Utils.logMessage(
        'Receive new notifcation, title: ${message.notification?.title}, body: ${message.notification?.body}');
    Utils.logMessage('Optional data in notification: ${message.data}');
    //Xử lý chuyển hướng đến conversation nhất định
    //Trước tiên, kiểm tra xem loại thông báo có phải là dạng thông báo tin nhắn không (message_notification)
    final data = message.data;
    if (data['type'] == 'message_notification') {
      //Xử lý việc chuyển hướng đến conversation mặc định
    }
  }

  void _navigateToConversation(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'message_notification') {
      //Chuyển hướng đến conversation
      final currentContext = _globalNavigatorKey?.currentContext;
      Utils.logMessage(
          'context truy cap trong FirebaseMessagingServer: $currentContext');
      if (currentContext != null) {
        //Chuyển hướng đến conversation
        GoRouter.of(currentContext).pushNamed(
          "chat",
          extra: data['conversationId'],
        );
      }
    }
  }

  Future<void> setUpInteractedMessage() async {
    //-----Xử  lý thông báo khi ở trạng thái terminated
    //Lấy tin nhắn khi ứng dụng ở chế độ terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    //Nếu có thông báo nhận được khi ứng dụng ở trạng thái terminated thì xử lý nó
    if (initialMessage != null) {
      _handleInteraction(initialMessage);
    }
    //-----Xử lý thông báo khi ứng dụng đang ở chế độ nền và người dùng
    //nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleInteraction(message);
      _navigateToConversation(message);
    });

    //Xử lý khi nhận thông báo khi ứng dụng đang chạy foreground
    FirebaseMessaging.onMessage.listen((message) {
      _handleInteraction(message);
      _createMessageNotification(message);
    });

    //Xử lý khi nhận thông báo khi ứng dụng đang chạy nền
    FirebaseMessaging.onBackgroundMessage(_messagingBackgroundHandler);
  }
}
