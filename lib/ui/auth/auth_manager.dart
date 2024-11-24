import 'dart:async';
import 'package:flutter/material.dart';
import 'package:job_finder_app/services/firebase_messaging_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/jobseeker.dart';
import '../../models/employer.dart';
import '../../services/auth_service.dart';
import '../../models/auth_token.dart';
import '../../services/socket_service.dart';
import '../../ui/shared/utils.dart';

class AuthManager with ChangeNotifier {
  AuthToken? _authToken;
  Timer? _authTimer;
  bool _isEmployer = false; //Biến quản lý loại người dùng
  late Jobseeker? _jobseeker;
  late Employer? _employer;
  SocketService? _socketService;

  final FirebaseMessagingService _firebaseAPI;
  final AuthService _authService = AuthService();

  AuthManager({required FirebaseMessagingService firebaseAPI})
      : _firebaseAPI = firebaseAPI;

  //Hàm kiểm tra đã đăng nhập vào chưa
  bool get isAuth {
    return authToken != null && authToken!.isValid;
  }

  bool get isEmployer {
    return _isEmployer;
  }

  AuthToken? get authToken {
    return _authToken;
  }

  Jobseeker? get jobseeker => _jobseeker;

  Employer? get employer => _employer;

  SocketService? get socketService => _socketService;

  //Hàm gán lại token
  Future<void> _setAuthToken(AuthToken token, bool isEmployer) async {
    _authToken = token;
    _isEmployer = isEmployer;
    if (isEmployer) {
      _employer = await _authService.fetchUserInfo(token.userId, isEmployer)
          as Employer;
    } else {
      _jobseeker = await _authService.fetchUserInfo(token.userId, isEmployer)
          as Jobseeker;
    }
    // _socketService = SocketService(token);
    // Always create a new SocketService instance
    _socketService?.disconnect();
    _socketService = SocketService(token);

    Utils.logMessage(
        'Socket trong _setAuthToken: ${_socketService?.socket?.hashCode}');
    _autoLogout();
    notifyListeners();
    Utils.logMessage('##1 - Goi ham _setAuthToken');
  }

  //Hàm đăng nhập vào tài khoản
  Future<void> login(String email, String password, bool isEmployer) async {
    Utils.logMessage('Đăng nhập nè');
    await _setAuthToken(
        await _authService.signIn(
          email: email,
          password: password,
          isEmployer: isEmployer,
        ),
        isEmployer);
    //Lấy thông tin người dùng
    Utils.logMessage('Đang chay');
    //Giải mã token để lấy exp hết hạn của token
    final token = _authToken?.token;
    //Nếu token hợp lệ thì giải mã token để lấy exp
    int exp = 0;
    if (token != null) {
      final decodeToken = JwtDecoder.decode(token);
      exp = decodeToken['exp'];
    } else {
      Utils.logMessage('Cannot extract token to get exp because it is null');
    }
    final isSavedRegistrationToken = await _authService.saveRegistrationToken(
      isEmployer,
      authToken!.userId,
      _firebaseAPI.registrationToken!,
      exp,
    );
    if (isSavedRegistrationToken) {
      Utils.logMessage('Luu registration token len DB thanh cong');
    } else {
      Utils.logMessage('That bai khi luu registration token');
    }
    //Hàm đánh dấu đang đang nhập cho một thiết bị, tưc là cập nhật lại ngày hết hạn của token mới này
    //Nếu trước đó người dùng không đăng xuất ra trong khi hết hạn, hạn cũ vẫn còn trên database tuy nhiên
    //nó đã hết hạn, và do đó khi thực hiện tác vụ khác thì kiểm tra xem nó còn hạn thì mới thực hiện.
    //lúc này người dùng đăng nhập lại nhưng hàm saveRegistrationToken trên sẽ không lưu lại registrationToken
    //đã tồn tại, do đó chạy hàm markLoginState để cập nhật lại hạn hết mới của token hiện tại
    final isMarkedLoginState = await _authService.markLoginState(
        isEmployer, authToken!.userId, _firebaseAPI.registrationToken!, exp);
    if (isMarkedLoginState) {
      Utils.logMessage("Marked loginState to true for this device");
    } else {
      Utils.logMessage("Encontered an exception or failed to mark this device");
    }
  }

  //Hàm đăng ký tài khoản
  Future<void> register(
      Map<String, String> submitedData, bool isEmployer) async {
    await _setAuthToken(
        await _authService.signup(
          firstName: submitedData['firstName'],
          lastName: submitedData['lastName'],
          phone: submitedData['phone'],
          email: submitedData['email'],
          password: submitedData['password'],
          address: submitedData['address'],
          role: submitedData['role'],
          companyName: submitedData['companyName'],
          companyEmail: submitedData['companyEmail'],
          companyPhone: submitedData['companyPhone'],
          companyAddress: submitedData['companyAddress'],
          otp: submitedData['otp'],
          isEmployer: isEmployer,
        ),
        isEmployer);
    // await _setAuthToken(
    //     await _authService.signIn(
    //       email: submitedData['email'],
    //       password: submitedData['password'],
    //       isEmployer: isEmployer,
    //     ),
    //     isEmployer);
    //Giải mã token để lấy exp hết hạn của token
    final token = _authToken?.token;
    //Nếu token hợp lệ thì giải mã token để lấy exp
    int exp = 0;
    if (token != null) {
      final decodeToken = JwtDecoder.decode(token);
      exp = decodeToken['exp'];
    } else {
      Utils.logMessage('Cannot extract token to get exp because it is null');
    }
    final isSavedRegistrationToken = await _authService.saveRegistrationToken(
      isEmployer,
      authToken!.userId,
      _firebaseAPI.registrationToken!,
      exp,
    );
    if (isSavedRegistrationToken) {
      Utils.logMessage('Luu registration token len DB thanh cong');
    } else {
      Utils.logMessage('That bai khi luu registration token');
    }
  }

  //Hàm đăng nhập tự động nếu mà token vẫn còn trong sharedPreference
  Future<bool> tryAutoLogin() async {
    final savedToken = await _authService.loadSavedAuthToken();
    if (savedToken == null) {
      return false;
    }

    _setAuthToken(savedToken, savedToken.isEmployer);
    return true;
  }

  //Hàm đăng xuất khởi ứng dụng, nếu token chưa hết hạn thì khi đăng
  //Xuất thì dừng thời gian của token lại và xóa nó bỏ
  Future<void> logout() async {
    //Đánh dấu thiết bị đã đăng xuất (đánh dấu loginState = false cho một registration token)
    //Nếu người dùng chủ động logout trong khi hạn của token hiện tại vẫn còn, do đó phải cập nhật lại hạn của token hiện tại
    //và làm nó hết hạn bằng cách đặt về 0 để nó khởi tạo về mấy chục năm về trước, đồng nghĩa với hết hạn.
    //Do đó khi làm tác vụ khác thì có thể biết là người dùng đã đăng nhập thiết bị này thông qua thời gian gán lại.
    final isMarkedLoginState = await _authService.markLoginState(
        isEmployer, authToken!.userId, _firebaseAPI.registrationToken!, 0);
    if (isMarkedLoginState) {
      Utils.logMessage(
          'Marked the loginState = false successfully because the user account have logged out from this device');
    } else {
      Utils.logMessage(
          'There is an exception or failure when trying to change the loginState');
    }

    //Reset lại các giá trị
    _authToken = null;
    _isEmployer = false;
    _jobseeker = null;
    _employer = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    await _authService.clearSavedAuthToken();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    Utils.logMessage(
        'token trong Preferences la: ${prefs.getString("authToken").toString()}');

    //Disconnect the socket
    _socketService?.disconnect();
    _socketService = null;
  }

  //hàm tự động đăng xuất khi token hết thời gian
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry =
        _authToken!.expiryDate.difference(DateTime.now()).inSeconds;
    Utils.logMessage('Thoi gian con lai cua token la: $timeToExpiry');
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      logout,
    );
  }

  //Hàm gửi OTP qua email
  Future<bool> sendOTP(
      {required String email, required bool isEmployer}) async {
    return await _authService.sendOTP(email, isEmployer);
  }
}
