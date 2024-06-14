import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/jobposting_service.dart';

import '../../models/jobposting.dart';

class JobpostingManager extends ChangeNotifier {
  List<Jobposting> _jobpostings = [];

  final JobpostingService _jobpostingService;

  JobpostingManager([AuthToken? authToken])
      : _jobpostingService = JobpostingService(authToken);

  set authToken(AuthToken? authToken) {
    _jobpostingService.authToken = authToken;
    notifyListeners();
  }

  List<Jobposting> get jobpostings => _jobpostings;

  //todo Hàm xáo trộn để đưa ra gợi ý ngẫu nhiên
  List<Jobposting> get randomJobposting {
    List<Jobposting> copy = [];
    for (int i = 0; i < _jobpostings.length; i++) {
      copy.add(_jobpostings[i]);
    }
    copy.shuffle(Random());
    return copy;
  }

  Future<void> fetchJobposting() async {
    final jobpostings = await _jobpostingService.fetchJobpostingList();
    if (jobpostings != null) {
      _jobpostings = jobpostings;
      notifyListeners();
    }
  }

  Future<void> changeFavoriteStatus(Jobposting jobposting) async {
    final savedState = jobposting.isFavorite;
    final isSuccess = await _jobpostingService.changeFavoriteState(
        !savedState, jobposting.id);
    if (isSuccess) {
      jobposting.isFavorite = !savedState;
    }
  }
}
