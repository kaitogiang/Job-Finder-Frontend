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
    //Xử lý notification tùy theo loại notification
    //Nếu là thông báo tin nhắn (message_notification) thì chuyển hướng đến conversation
    Utils.logMessage(
        'Received action: ${receivedAction.title} ${receivedAction.payload}');
    if (receivedAction.payload?['type'] == 'message_notification') {
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
    } else if (receivedAction.payload?['type'] == 'download_notification') {
      //Xử lý notification tải xuống file
      Utils.logMessage('Mở folder');
      //todo open the image folder

      // await OpenFile.open('/storage/emulated/0/Download/');
      // Get the path to the directory
      openFileManager(
        androidConfig: AndroidConfig(
          folderType: FolderType.download,
        ),
      );
    } else if (receivedAction.payload?['type'] == 'normal_notification') {
      final target = receivedAction.payload?['target'];
      //Nếu đối tượng nhận thông báo là jobseeker thì thực hiện
      if (target == "jobseeker") {
        //Chuyển hướng đến trang xem danh sách kết quả
        if (navigatorKey?.currentState != null) {
          //Chuyển hướng đến conversation
          final currentContext = navigatorKey?.currentContext;
          if (currentContext != null) {
            //Chuyển hướng đến conversation
            GoRouter.of(currentContext).goNamed(
              "saved-work",
            );
          }
        }
      } else if (target == "employer") {
        //Thực hiện xử lý đối với thông báo tới employer
        //Chuyển hướng đến tab ứng viên
        if (navigatorKey?.currentState != null) {
          //Chuyển hướng đến conversation
          final currentContext = navigatorKey?.currentContext;
          if (currentContext != null) {
            //Chuyển hướng đến conversation
            GoRouter.of(currentContext).goNamed(
              "application-list",
            );
          }
        }
      }
    }
  }
}
