import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
      List<String> favoritePosts = favorteResponse.isNotEmpty
          ? favorteResponse
              .map(
                (e) => e as String,
              )
              .toList()
          : [];
      log('List<Jobposting> đã nạp: ${response.length}');
      log('Favorite hien tai la: ${favoritePosts.length}');
      //? Danh sách tất cả các bài tuyển dụng
      List<Map<String, dynamic>> list =
          response.map((e) => e as Map<String, dynamic>).toList();
      //todo Kết hợp lại với favorite, chuyển đổi thuộc tính isFavorite của từng
      //todo phần tử nếu nó có trong danh sách favoritePosts
      if (favoritePosts.isNotEmpty) {
        List<Jobposting> jobpostingList =
            list.map((e) => Jobposting.fromJson(e)).toList();
        //todo kiểm tra xem bài viết có trong favoritePost không
        for (Jobposting post in jobpostingList) {
          if (favoritePosts.contains(post.id)) {
            post.isFavorite = true;
          }
        }
        return jobpostingList;
      } else {
        List<Jobposting> jobpostingList =
            list.map((e) => Jobposting.fromJson(e)).toList();
        return jobpostingList;
      }
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

  Future<List<Jobposting>?> getCompanyJobposting(String companyId) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/company/$companyId',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      List<Map<String, dynamic>> convertedResponse =
          response.map((post) => post as Map<String, dynamic>).toList();
      // log('List<Map<String, dynamic la>>: ${convertedResponse.toString()}');
      List<Jobposting> jobList =
          convertedResponse.map((e) => Jobposting.fromJson(e)).toList();

      return jobList;
    } catch (error) {
      log('Error in getCompanyJobposting - Jobposting Service: $error');
      return null;
    }
  }

  Future<Jobposting?> createJobposting(Jobposting job) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/create',
        headers: headers,
        method: HttpMethod.post,
        body: jsonEncode({
          ...job.toJson(),
          'companyId': decodedToken['companyId'],
        }),
      ) as Map<String, dynamic>;

      Map<String, dynamic> newJobposting =
          response['newPost'] as Map<String, dynamic>;

      return Jobposting.fromJson(newJobposting);
    } catch (error) {
      log('Error in createJobposting - Jobposting Service: $error');
      return null;
    }
  }

  Future<Jobposting?> updatePost(Jobposting updatedPost) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/${updatedPost.id}',
        headers: headers,
        method: HttpMethod.patch,
        body: jsonEncode(updatedPost.toJson()),
      ) as Map<String, dynamic>;
      Jobposting editedJob =
          Jobposting.fromJson(response['updatedPost'] as Map<String, dynamic>);
      return editedJob;
    } catch (error) {
      log('Error in updatePost - jobposting service: $error');
      return null;
    }
  }

  Future<bool> deletePost(String id) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/$id',
        headers: headers,
        method: HttpMethod.delete,
      );
      return true;
    } catch (error) {
      log('Error in deletePost - jobposting service: $error');
      return false;
    }
  }
}
