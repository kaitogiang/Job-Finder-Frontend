import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/socket_service.dart';

class MessageManager extends ChangeNotifier {
  SocketService? _socketService;

  MessageManager([AuthToken? authToken])
      : _socketService = SocketService(authToken);

  set socketService(SocketService? socketService) {
    _socketService = socketService;
    notifyListeners();
  }
}
