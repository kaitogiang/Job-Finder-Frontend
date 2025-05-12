import 'dart:convert';
import 'dart:developer';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JobpostingService extends NodeService {
  JobpostingService([super.authToken]);

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

      //todo Must convert each element to a string to be able to cast
      List<String> favoritePosts = favorteResponse.isNotEmpty
          ? favorteResponse
              .map(
                (e) => e as String,
              )
              .toList()
          : [];
      log('List<Jobposting> loaded: ${response.length}');
      log('Current favorite is: ${favoritePosts.length}');
      //? List of all job postings
      List<Map<String, dynamic>> list =
          response.map((e) => e as Map<String, dynamic>).toList();
      //todo Combine with favorite, convert the isFavorite attribute of each
      //todo element if it is in the favoritePosts list
      if (favoritePosts.isNotEmpty) {
        List<Jobposting> jobpostingList =
            list.map((e) => Jobposting.fromJson(e)).toList();
        //todo check if the post is in favoritePost
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
  //Function to get job suggestions
  Future<List<Jobposting>?> fetchJobpostingSuggestionList() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/suggestJob/$userId',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      final favorteResponse = await httpFetch(
        '$databaseUrl/api/jobposting/user/$userId/favorite',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;

      //todo Must convert each element to a string to be able to cast
      List<String> favoritePosts = favorteResponse.isNotEmpty
          ? favorteResponse
              .map(
                (e) => e as String,
              )
              .toList()
          : [];
      log('List<Jobposting> loaded: ${response.length}');
      log('Current favorite is: ${favoritePosts.length}');
      //? List of all job postings
      List<Map<String, dynamic>> list =
          response.map((e) => e as Map<String, dynamic>).toList();
      //todo Combine with favorite, convert the isFavorite attribute of each
      //todo element if it is in the favoritePosts list
      if (favoritePosts.isNotEmpty) {
        List<Jobposting> jobpostingList =
            list.map((e) => Jobposting.fromJson(e)).toList();
        //todo check if the post is in favoritePost
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
      //todo check the value of value, if it is true then add it to
      //todo the favorite list, otherwise remove it from the favorite list
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
      await httpFetch(
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

  //Additional services for admin
  //Function to get all job postings including expired posts
  Future<List<Jobposting>> getAllJobpostings() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/all',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      if (response.isEmpty) {
        return [];
      }
      //Convert each element to Map<String, dynamic>
      List<Map<String, dynamic>> jobpostingMapList =
          List<Map<String, dynamic>>.from(response);
      //Convert each element to jobposting
      List<Jobposting> jobpostingList = jobpostingMapList
          .map((jobposting) => Jobposting.fromJson(jobposting))
          .toList();
      return jobpostingList;
    } catch (error) {
      Utils.logMessage(
          'Error in getAllJobpostings - Jobposting Service: $error');
      return [];
    }
  }

  //Function to load recent job postings, within a week
  Future<List<Jobposting>> getRecentJobpostings() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/recent',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      //Convert each element in the list to Map<String, dynamic>
      final recentJobpostingMapList = List<Map<String, dynamic>>.from(response);
      //Convert each element in the array above from Map to Jobposting
      final recentJobpostingList = recentJobpostingMapList
          .map((jobposting) => Jobposting.fromJson(jobposting))
          .toList();
      return recentJobpostingList;
    } catch (error) {
      Utils.logMessage(
          'Error in getRecentJobposting - Jobposting Service: $error');
      return [];
    }
  }

  //Function to return the number of favorites for each JobpostingId
  Future<List<Map<String, dynamic>>> getFavoriteNumberOfJobpostings() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/all/favorite-numbers',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      //Convert each element to map
      final responseMap = List<Map<String, dynamic>>.from(response);
      //Only return elements that have favorites
      final favoriteList = responseMap.where((favorite) {
        final favoriteCount = favorite['favoriteCount'] as int;
        return favoriteCount > 0;
      }).toList();
      //Convert List to Map<String, int> and return it if it has elements
      if (favoriteList.isEmpty) {
        return [];
      } else {
        return favoriteList;
      }
    } catch (error) {
      Utils.logMessage('Error in getFavoriteNumberOfJobpostings: $error');
      return [];
    }
  }

  Future<Jobposting?> getJobpostingById(String jobpostingId) async {
    try {
      final response = await httpFetch(
          '$databaseUrl/api/jobposting/$jobpostingId',
          headers: headers,
          method: HttpMethod.get) as Map<String, dynamic>;
      //Convert the type of response to Jobposting
      final receivedJobposting = Jobposting.fromJson(response);

      return receivedJobposting;
    } catch (error) {
      Utils.logMessage('Error in getJobpostingById: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getJobpostingFavoriteCount(String id) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobposting/$id/favorite-number',
        headers: headers,
        method: HttpMethod.get,
      ) as Map<String, dynamic>;
      return response;
    } catch (error) {
      Utils.logMessage('Error in getJobpostingFavoriteCount: $error');
      return null;
    }
  }
}
