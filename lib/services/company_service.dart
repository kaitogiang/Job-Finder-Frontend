import 'dart:developer';
import 'dart:io';

import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CompanyService extends NodeService {
  CompanyService([AuthToken? authToken]) : super(authToken);

  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  Future<Company?> fetchCompanyInfo() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    try {
      final respone = await httpFetch(
          '$databaseUrl/api/company/${decodedToken['companyId']}',
          headers: headers,
          method: HttpMethod.get) as Map<String, dynamic>;
      return Company.fromJson(respone);
    } catch (error) {
      log('Error in fetchCompanyInfo - service: $error');
      return null;
    }
  }

  Future<Company?> updateCompanyInfo(
      File? file, List<File>? images, Company company) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    log(company.toString());
    try {
      final response = await httpUpload(
        '$databaseUrl/api/company/${decodedToken['companyId']}',
        fields: company.toJson(),
        file: file,
        images: images,
      ) as Map<String, dynamic>;
      String avatar = response['avatarLink'];
      log(response.toString());
      return Company.fromJson({...response['updateCompany'], 'avatar': avatar});
    } catch (error) {
      log('Error in updateCompanyInfo - service: $error');
      return null;
    }
  }
}
