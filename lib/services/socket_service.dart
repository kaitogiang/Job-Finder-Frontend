import 'dart:async';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../ui/shared/utils.dart';

class SocketService {
  io.Socket? socket;
  AuthToken? _authToken;

  final StreamController<Map<String, dynamic>> _jobpostingController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get jobpostingStream =>
      _jobpostingController.stream;

  SocketService(this._authToken) {
    Utils.logMessage("TOken trong socket: ${_authToken?.token}");
    _initializeSocket();
  }

  void _initializeSocket() {
    log('Initializing socket');
    //Khi sử dụng hàm io.io() thì socket sẽ không được tạo mới mà sử dụng lại socket cũ
    // Nếu io.io('http://localhost:3000') được gọi lần đầu tiên và sau đó bạn tạo mới
    //lớp SocketService, nhưng vẫn dùng lại cùng một URI (http://localhost:3000),
    //có khả năng Manager của Socket.IO vẫn giữ tham chiếu đến kết nối cũ,
    //ngay cả khi bạn đã ngắt kết nối trước đó.
    //Bởi vì manager sử dụng lại tham chiếu của socket cũ nên những thiết lập như gửi token
    //sẽ sử dụng token của lần khởi tạo socket đầu tiên
    //Để tránh điều này, bạn có thể sử dụng thêm .enableForceNew() trong OptionBuilder
    //Sử dụng hàm .enableForceNew() sẽ tạo ra một kết nối mới mỗi khi gọi đến hàm io.io(),
    //có nghĩa là một tham chiếu mới được tạo ra và token sẽ được gửi đi mỗi lần
    Utils.logMessage(
        "Khoi tao lai socket service voi token: ${_authToken?.token}");
    socket = io.io(
      dotenv.env['DATABASE_BASE_URL'],
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': _authToken?.token,
          })
          .enableForceNew()
          .setTimeout(10000)
          // .enableReconnection()
          // .setReconnectionAttempts(3)
          // .setReconnectionDelay(2000)
          // .setReconnectionDelayMax(5000)
          .build(),
    );
    //Khi bỏ hai tham số trên thì manager trong socket sẽ tái sử dụng lại tham chiếu
    //socket cũ bởi vì cùng uri
    //Nhưng mỗi lần tạo mới, mặc dù là nó tái sử dụng lại socket nhưng token thì
    //mình lại gán mới lại nên vẫn chạy ổn định, không có sử dụng token cũ
    // socket?.auth = {
    //   'token': _authToken?.token,
    // };
    _setupSocketListeners();
    _connectSocket();
  }

  void _setupSocketListeners() {
    socket?.onConnect((_) {
      Utils.logMessage("Connected to the socket server");
    });

    socket?.onConnectError((reason) {
      Utils.logMessage("Connection error: $reason");
    });

    socket?.onDisconnect((reason) {
      Utils.logMessage("Disconnected from the socket server, reason: $reason");
    });

    socket?.onReconnectAttempt((data) {
      Utils.logMessage("Reconnect: ${data.toString()}");
      Utils.logMessage("Reconnect attempt....[${socket?.auth}]");
      Utils.logMessage("Reconnect attempt...., token: ${_authToken?.token}");
    });

    socket?.onReconnect((_) {
      Utils.logMessage("Reconnected to the socket server");
    });

    socket?.onReconnectFailed((_) {
      Utils.logMessage("Reconnect failed");
    });

    //Lắng nghe sự kiện cập nhật jobposting
    _listenToJobpostingChanges();
  }

  void _connectSocket() {
    socket?.connect();
    Utils.logMessage('Socket connection status: ${socket?.connected}');
  }

  void updateAuthToken(AuthToken? authToken) {
    _authToken = authToken;
    socket?.disconnect();
    _initializeSocket();
  }

  void disconnect() {
    socket?.disconnect();
    socket?.close();
    socket?.dispose();
    _jobpostingController.close();
  }

  void dispose() {
    socket?.dispose();
    _jobpostingController.close();
  }

  void _listenToJobpostingChanges() {
    Utils.logMessage("Lắng nghe sự kiện cập nhật jobposting");
    socket?.on("jobposting:modified", (data) {
      Utils.logMessage("Có dữ liệu mới đến của jobposting");
      _jobpostingController.add(data);
    });
  }

  // void listenToJobpostingChanges(Function(Map<String, dynamic>) onAction) {
  //   socket?.on("jobposting:modified", (data) {
  //     Utils.logMessage("Có dữ liệu mới đến của jobposting");
  //     onAction(data);
  //   });
  // }
}
