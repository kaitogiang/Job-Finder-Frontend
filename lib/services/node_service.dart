import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:http/http.dart' as http;
import 'package:job_finder_app/models/http_exception.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

enum HttpMethod { get, post, put, patch, delete }

abstract class NodeService {
  String? _token;
  String? _userId;
  late final String? databaseUrl;

  NodeService([AuthToken? authToken])
      : _token = authToken?.token,
        _userId = authToken?.userId {
    databaseUrl = kIsWeb
        ? dotenv.env['DATABASE_BASE_URL_WEB']
        : dotenv.env['DATABASE_BASE_URL'];
  }

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
    http.Response response;
    switch (method) {
      case HttpMethod.get:
        response = await http.get(requestUri, headers: headers);
        break;
      case HttpMethod.post:
        response = await http.post(requestUri, headers: headers, body: body);
        break;
      case HttpMethod.put:
        response = await http.put(requestUri, headers: headers, body: body);
        break;
      case HttpMethod.patch:
        response = await http.patch(requestUri, headers: headers, body: body);
        break;
      case HttpMethod.delete:
        response = await http.delete(requestUri, headers: headers);
        break;
    }
    final json = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw HttpException(json['message']);
    }
    return json;
  }

  Future<dynamic> httpUpload(
    String uri, {
    required Map<String, String> fields,
    File? file,
    List<File>? images,
    String? fileFieldName = 'avatar',
  }) async {
    Uri requestUri = Uri.parse(uri);
    final request = http.MultipartRequest('PATCH', requestUri);

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    if (file != null) {
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mimeTypeData = mimeType.split('/');
      final multipartFile = await http.MultipartFile.fromPath(
        fileFieldName!,
        file.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        filename: basename(file.path),
      );
      request.files.add(multipartFile);
    }

    if (images != null) {
      for (var image in images) {
        final mimeType =
            lookupMimeType(image.path) ?? 'application/octet-stream';
        final mimeTypeData = mimeType.split('/');
        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          filename: basename(image.path),
        );
        request.files.add(multipartFile);
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final json = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw HttpException(json['message']);
    }
    return json;
  }
}
