
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:http/http.dart' as http;
import 'package:job_finder_app/models/http_exception.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';


enum HttpMethod {get, post, put, patch, delete}

abstract class NodeService {
  String? _token;
  String? _userId;

  late final String? databaseUrl;

  NodeService([AuthToken? authToken]) 
  : _token = authToken?.token,
  _userId = authToken?.userId,
  databaseUrl = 'http://localhost:3000/';

  set authToken(AuthToken? authToken) {
    _token = authToken?.token;
    _userId = authToken?.userId;
  }

  @protected
  String? get token => _token;

  @protected
  String? get userId => _userId;

  Future<dynamic> httpFetch(
    String uri, {
      HttpMethod method = HttpMethod.get,
      Map<String, String>? headers,
      Object? body,
    }) async {
      Uri requestUri = Uri.parse(uri);
      http.Response response = switch(method) {
        HttpMethod.get => await http.get(
          requestUri,
          headers: headers,
        ),
        HttpMethod.post => await http.post(
          requestUri,
          headers: headers,
          body: body
        ),
        HttpMethod.put => await http.put(
          requestUri,
          headers: headers,
          body: body
        ),
        HttpMethod.patch => await http.patch(
          requestUri,
          headers: headers,
          body: body
        ),
        HttpMethod.delete => await http.delete(
          requestUri,
          headers: headers,
        ),
      };
      final json = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw HttpException(json['message']);
      }

      return json;
    }

  Future<dynamic> httpUpload(
    String uri, {
      required Map<String, String> fields,
      required File file,
    }) async {
      Uri requestUri = Uri.parse(uri);
      final request = http.MultipartRequest('POST', requestUri);

      //Thêm token vào headers
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      //Thêm các trường nhập vào form
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      //Xác định loại của file tải lên
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mimeTypeData = mimeType.split('/');

      //Thêm file vào trong yêu cầu
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        filename: basename(file.path),
      );

      request.files.add(multipartFile);

      //Gửi yêu cầu cho server
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final json = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw HttpException(json['message']);
      }
      return json;
    }

}