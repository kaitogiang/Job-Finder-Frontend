import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket socket;
  AuthToken? _authToken;

  SocketService(this._authToken) {
    _initializeSocket();
  }

  void _initializeSocket() {
    log('Initializing socket');
    log('Token in SocketService: ${_authToken?.token}');

    socket = io.io(
      dotenv.env['DATABASE_BASE_URL'],
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': _authToken?.token,
          })
          .build(),
    );

    _setupSocketListeners();
    _connectSocket();
  }

  void _setupSocketListeners() {
    socket
      ..on('connect', (_) => log('Connected to the socket server'))
      ..onConnectError((reason) => log('Connection error: $reason'))
      ..onDisconnect((_) => log('Disconnected from the socket server'));
  }

  void _connectSocket() {
    socket.connect();
    log('Socket connection status: ${socket.connected}');
  }

  void updateAuthToken(AuthToken? authToken) {
    _authToken = authToken;
    socket.disconnect();
    _initializeSocket();
  }

  void disconnect() {
    socket.disconnect();
  }
}
