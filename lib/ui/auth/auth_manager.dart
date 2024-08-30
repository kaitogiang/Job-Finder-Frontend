import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/jobseeker.dart';
import '../../models/employer.dart';
import '../../services/auth_service.dart';
import '../../models/auth_token.dart';
import '../../services/socket_service.dart';

class AuthManager with ChangeNotifier {
  AuthToken? _authToken;
  Timer? _authTimer;
  bool _isEmployer = false; //Biến quản lý loại người dùng
  late Jobseeker? _jobseeker;
  late Employer? _employer;
  SocketService? _socketService;

  final AuthService _authService = AuthService();

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
    _socketService = SocketService(token);
    _autoLogout();
    notifyListeners();
  }

  //Hàm đăng nhập vào tài khoản
  Future<void> login(String email, String password, bool isEmployer) async {
    log("Đăng nhập nè");
    await _setAuthToken(
        await _authService.signIn(
          email: email,
          password: password,
          isEmployer: isEmployer,
        ),
        isEmployer);
    //Lấy thông tin người dùng
    log("Đang chay");
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
    log('token trong Preferences la: ' +
        prefs.getString("authToken").toString());
  }

  //hàm tự động đăng xuất khi token hết thời gian
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry =
        _authToken!.expiryDate.difference(DateTime.now()).inSeconds;
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
