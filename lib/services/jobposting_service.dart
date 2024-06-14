import 'dart:developer';

import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/services/node_service.dart';

import '../models/company.dart';

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
      List<Map<String, dynamic>> list =
          response.map((e) => e as Map<String, dynamic>).toList();

      return list.map((e) => Jobposting.fromJson(e)).toList();
    } catch (error) {
      log('Error in fetchJobpostingList - Job service: $error');
      return null;
    }
  }
}
