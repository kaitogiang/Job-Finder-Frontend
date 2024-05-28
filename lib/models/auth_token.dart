class AuthToken {
  final String _token;
  final String _userId;
  final String _email;
  final DateTime _expiryDate;
  final bool _isEmployer;

  //Hàm khởi tạo AuthToken chứa thông tin của người dùng đăng nhập vào
  AuthToken({
    token,
    userId,
    email,
    expiryDate,
    isEmployer
  }) : _token = token,
      _userId = userId,
      _email = email,
      _expiryDate = expiryDate,
      _isEmployer = isEmployer;

  //Kiểm tra token có hợp không, tức là còn hạn không, nếu hết hạn
  //Tức là không hợp lệ
  bool get isValid {
    return token != null;
  }
  //Hàm trả về token nếu nó hợp lệ, có nghĩa là
  //Token còn hạn. Nếu mà _expiryDate nằm sau thời
  //Gian hiện tại. Tức là nó còn hạn.
  String? get token {
    if (_expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  String get email {
    return _email;
  }

  DateTime get expiryDate {
    return _expiryDate;
  }

  bool get isEmployer {
    return _isEmployer;
  }

  Map<String, dynamic> toJson() {
    return {
      'authToken': _token,
      'userId': _userId,
      'email': _email,
      'expiryDate': _expiryDate.toIso8601String(),
      'isEmployer': _isEmployer
    };
  }

  static AuthToken fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['authToken'],
      userId: json['userId'],
      email: json['email'],
      expiryDate: DateTime.parse(json['expiryDate']),
      isEmployer: json['isEmployer']
    );
  }

}
