import 'dart:async';

import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/auth_service.dart';

class AdminAuthManager extends ChangeNotifier {
  AuthToken? _authToken;
  Timer? _authTimer;

  String _name = '';

  final AuthService _authService = AuthService();

  bool get isAuth {
    return _authToken != null && _authToken!.isValid;
  }

  AuthToken? get authToken {
    return _authToken;
  }

  String get name {
    return _name;
  }

  Future<void> _setAuthToken(AuthToken token) async {
    _authToken = token;
    _autoLogout();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    Utils.logMessage('Đăng nhập admin');
    _name = await _authService.getAdminName(email);
    await _setAuthToken(
      await _authService.signInAdmin(email, password),
    );
  }

  Future<bool> tryAutoLogin() async {
    final savedToken = await _authService.loadSavedAuthToken();
    if (savedToken == null) {
      return false;
    }
    _setAuthToken(savedToken);
    return true;
  }

  Future<void> logout() async {
    _authToken = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    await _authService.clearSavedAuthToken();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry =
        _authToken!.expiryDate.difference(DateTime.now()).inSeconds;
    Utils.logMessage('Thoi gian con lai cua admin: $timeToExpiry');
    _authTimer = Timer(
      Duration(seconds: timeToExpiry),
      logout,
    );
  }

  Future<bool> sendOTP(String email) async {
    return await _authService.sendOTPAdmin(email);
  }

  Future<bool> resetPassword(String email, String password, String otp) async {
    return await _authService.resetAdminPassword(email, password, otp);
  }
}
