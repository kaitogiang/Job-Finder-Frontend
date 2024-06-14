import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/services/node_service.dart';

class JobpostingService extends NodeService {
  JobpostingService([AuthToken? authToken]) : super(authToken);

  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  Future<List<Jobposting>?> fetchJobpostingList() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      final favorteResponse = await httpFetch(
        '$databaseUrl/api/jobposting/user/$userId/favorite',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      //todo Phải chuyển mỗi phần tử thành chuỗi thì mới ép kiểu được
      List<String> favoritePosts = favorteResponse
          .map(
            (e) => e as String,
          )
          .toList();
      //? Danh sách tất cả các bài tuyển dụng
      List<Map<String, dynamic>> list =
          response.map((e) => e as Map<String, dynamic>).toList();
      //todo Kết hợp lại với favorite, chuyển đổi thuộc tính isFavorite của từng
      //todo phần tử nếu nó có trong danh sách favoritePosts
      List<Jobposting> jobpostingList =
          list.map((e) => Jobposting.fromJson(e)).toList();
      //todo kiểm tra xem bài viết có trong favoritePost không
      for (Jobposting post in jobpostingList) {
        if (favoritePosts.contains(post.id)) {
          post.isFavorite = true;
        }
      }
      return jobpostingList;
    } catch (error) {
      log('Error in fetchJobpostingList - Job service: $error');
      return null;
    }
  }

  Future<bool> changeFavoriteState(bool value, String jobpostingId) async {
    try {
      //todo kiểm tra xem giá trị của value, nếu là true tức là thêm nó vào
      //todo danh sách yêu thích, ngược lại thì xóa nó khỏi danh sách yêu thích
      if (value) {
        await httpFetch('$databaseUrl/api/jobposting/user/$userId/favorite',
            headers: headers,
            method: HttpMethod.post,
            body: jsonEncode({'jobpostingId': jobpostingId}));
        return true;
      } else {
        await httpFetch('$databaseUrl/api/jobposting/user/$userId/favorite',
            headers: headers,
            method: HttpMethod.patch,
            body: jsonEncode({'jobpostingId': jobpostingId}));
        return true;
      }
    } catch (error) {
      log('Error in changeFavoriteState - Job service: $error');
      return false;
    }
  }
}
