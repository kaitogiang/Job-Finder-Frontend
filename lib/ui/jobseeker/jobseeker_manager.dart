import 'package:flutter/material.dart';
import 'package:job_finder_app/models/jobseeker.dart';

class JobseekerManager extends ChangeNotifier {
  Jobseeker _jobseeker;
  
  JobseekerManager([Jobseeker? jobseeker]) : _jobseeker = jobseeker!;

  Jobseeker get jobseeker => _jobseeker;

  List<String> get skills => _jobseeker.skills;


  void addSkill(String skill) {
    skills.add(skill);
    notifyListeners();
  }

  void removeSkill(String skill) {
    skills.remove(skill);
    notifyListeners();
  }
}