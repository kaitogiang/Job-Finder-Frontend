
import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/auth_token.dart';

class AuthManager with ChangeNotifier {
  AuthToken? _authToken;
  Timer? _authTimer;
  bool _isEmployer = false; //Biến quản lý loại người dùng

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

  //Hàm gán lại token
  void _setAuthToken(AuthToken token, bool isEmployer) {
    _authToken = token;
    _isEmployer = isEmployer;
    _autoLogout();
    notifyListeners();
  }

  //Hàm đăng nhập vào tài khoản
  Future<void> login(String email, String password, bool isEmployer) async {
    _setAuthToken(await _authService.signIn(
      email: email,
      password: password,
      isEmployer: isEmployer,
    ), isEmployer);
  }

  //Hàm đăng ký tài khoản


  //Hàm đăng nhập tự động nếu mà token vẫn còn trong sharedPreference
  Future<bool> tryAutoLogin() async {
    final savedToken = await _authService.loadSavedAuthToken();
    if (savedToken == null) {
      return false;
    }

    _setAuthToken(savedToken, _isEmployer);
    return true;
  }

  //Hàm đăng xuất khởi ứng dụng, nếu token chưa hết hạn thì khi đăng
  //Xuất thì dừng thời gian của token lại và xóa nó bỏ
  Future<void> logout() async {
    _authToken = null;
    _isEmployer = false;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    _authService.clearSavedAuthToken();
  }

  //hàm tự động đăng xuất khi token hết thời gian
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _authToken!.expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      logout,
    );
  }

  //Hàm gửi OTP qua email
  Future<bool> sendOTP({required String email, required bool isEmployer}) async {
    return await _authService.sendOTP(email, isEmployer);
  }
}