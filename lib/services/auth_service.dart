import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:http/http.dart' as http;
import 'package:job_finder_app/models/employer.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jobseeker.dart';
import '../models/http_exception.dart';

class AuthService {
  static const _authTokenKey = 'authToken';
  late final String? _baseUrl;

  AuthService() {
    _baseUrl = dotenv.env['DATABASE_BASE_URL'];
  }
  //Hàm xác định url dành cho loại người đăng nhập hiện tại
  //Nếu isEmployer là true tức là nhà tuyển dụng đăng nhập
  //Thì sử dụng api dành cho nhà tuyển dụng, ngược lại dành cho người tìm việc
  String _buildAuthUrl(bool isEmployer) {
    return isEmployer
        ? '$_baseUrl/api/employer/sign-in'
        : '$_baseUrl/api/jobseeker/sign-in';
  }

  //Hàm xác thực đăng nhập
  Future<AuthToken> _authenticate(
      String email, String password, bool isEmployer) async {
    try {
      final url = Uri.parse(_buildAuthUrl(isEmployer));
      final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({'email': email, 'password': password}));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseJson = json.decode(response.body);
        log('Đang trong auth_service: ' + responseJson.toString());
        final token = responseJson['token'];
        //decode token to get information
        if (token != null) {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          log('Đang trong auth_service: ' + decodedToken.toString());
          final authToken = _fromJson(responseJson);
          //lưu trữ lại AuthToken để đăng nhập tự động khi còn thời gian
          await _saveAuthToken(authToken);
          return authToken;
        } else {
          throw HttpException('Token not found');
        }
      } else {
        final errorResponse = json.decode(response.body);
        throw HttpException.fromJson(errorResponse);
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  //Hàm đăng nhập vào ứng dụng
  Future<AuthToken> signIn(
      {String? email, String? password, bool isEmployer = false}) async {
    return _authenticate(email!, password!, isEmployer);
  }

  //Hàm nạp dữ liệu người dùng
  Future<dynamic> fetchUserInfo(String id, bool isEmployer) async {
    String url = '';
    if (isEmployer) {
      url = '$_baseUrl/api/employer/$id';
    } else {
      url = '$_baseUrl/api/jobseeker/$id';
    }
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseJson = json.decode(response.body) as Map<String, dynamic>;
      log('Dữ liệu fetch trong response: $responseJson');
      // final list = responseJson['skills'] as List<dynamic>;
      // log('Hàm fetchUserInfo auth_servie ' + list.toString());
      // list.forEach((element) {
      //   String e = element as String;
      //   log(e);
      // });
      //Trả về đối tượng tùy theo loại của chúng, khi lấy dữ liệu thì chỉ cần ép kiểu là được
      return isEmployer
          ? Employer.fromJson(responseJson)
          : Jobseeker.fromJson(responseJson);
    } else {
      final errorResponse = json.decode(response.body);
      log(errorResponse.toString());
      throw HttpException.fromJson(errorResponse);
    }
  }

  //Hàm đăng ký tài khoản theo từng người dùng
  Future<AuthToken> signup({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? role,
    String? companyName,
    String? companyEmail,
    String? companyPhone,
    String? companyAddress,
    String? otp,
    bool isEmployer = false,
  }) async {
    //Tạo dữ liệu JSon để gửi cho server
    Map<String, dynamic> jsonValue = {};
    String api = '';
    //Đăng ký tài khoản cho nhà tuyển dụng
    if (isEmployer) {
      api = '$_baseUrl/api/employer/sign-up';
      jsonValue = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'role': role,
        'companyName': companyName,
        'companyEmail': companyEmail,
        'companyPhone': companyPhone,
        'companyAddress': companyAddress,
        'otp': otp,
      };
    } else {
      //Đăng ký tài khoản cho người tìm việc
      api = '$_baseUrl/api/jobseeker/sign-up';
      jsonValue = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'otp': otp,
      };
    }
    //Gửi dữ liệu về server xử lý
    try {
      final url = Uri.parse(api);
      final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(jsonValue));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        //Khi đăng ký xong thì đăng nhập ứng dụng
        return _authenticate(
            jsonValue['email'], jsonValue['password'], isEmployer);
      } else {
        final errorResponse = json.decode(response.body);
        throw HttpException.fromJson(errorResponse);
      }
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  //Hàm lưu trữ AuthToken vào share Preferences
  Future<void> _saveAuthToken(AuthToken authToken) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_authTokenKey, json.encode(authToken.toJson()));
  }

  //Hàm lấy token đang được lưu trữ nếu có
  Future<AuthToken?> loadSavedAuthToken() async {
    //Truy xuất đến SharedPrefereneces để lấy những gì được lưu trữ
    final prefs = await SharedPreferences.getInstance();
    //Kiểm tra xem trong SharedPreferences có khóa 'authToken', nếu
    //Có tức là AuthToken được lưu trữ trong khóa 'authToken'. Trong
    //SharedPreferences thì lưu trữ theo được key-value
    if (!prefs.containsKey(_authTokenKey)) {
      return null;
    }
    //Lấy giá trị của key 'authtoken', hiện tại nó đang ở dạng chuỗi
    //Tức là Object được chuyển thành chuỗi
    final savedToken = prefs.getString(_authTokenKey);
    //Chuyển kiểu chuỗi JSOn thành đối tượng AuthToken và kiểm tra xem
    //Token còn hạn không, nếu không còn thì thôi
    final authToken = AuthToken.fromJson(json.decode(savedToken!));
    if (!authToken.isValid) {
      return null;
    }
    return authToken;
  }

  //Hàm xóa AuthToken khỏi SharedPreference khi người dùng đăng xuất hoặc
  //Khi token hết hạn
  Future<void> clearSavedAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_authTokenKey);
  }

  //Hàm chuyển đổi chuỗi JSOn thành đối tượng của AuthToken
  AuthToken _fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final decodeToken = JwtDecoder.decode(token);
    final userId = decodeToken['_id'];
    final email = decodeToken['email'];
    final isEmployer = json['isEmployer'];
    return AuthToken(
      token: token,
      userId: userId,
      email: email,
      expiryDate: DateTime.now().add(Duration(seconds: json['expiresIn'])),
      isEmployer: isEmployer,
    );
  }

  //Hàm gửi OTP qua email
  Future<bool> sendOTP(String email, bool isEmployer) async {
    String uri = !isEmployer
        ? '$_baseUrl/api/jobseeker/send-otp'
        : '$_baseUrl/api/employer/send-otp';
    try {
      final url = Uri.parse(uri);
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'email': email}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final errorResponse = json.decode(response.body);
        throw HttpException.fromJson(errorResponse);
      }
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }
}
