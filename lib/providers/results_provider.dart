import 'package:flutter/material.dart';
import '../domain/models/academic_result.dart';
import '../data/local/result_dao.dart';

class ResultsProvider extends ChangeNotifier {
  final ResultDao _dao = ResultDao();

  List<AcademicResult> _results = [];
  bool _isLoading = false;

  List<AcademicResult> get results => _results;
  bool get isLoading => _isLoading;

  // Analytics Helpers
  double get cgpa {
    if (_results.isEmpty) return 0.0;
    double totalQualityPoints = 0;
    int totalCredits = 0;
    for (var r in _results) {
      totalQualityPoints += r.gpa * r.credits;
      totalCredits += r.credits;
    }
    return totalCredits == 0 ? 0.0 : totalQualityPoints / totalCredits;
  }

  String get degreeClass {
    final val = cgpa;
    if (val >= 3.70) return 'First Class';
    if (val >= 3.30) return 'Second Class (Upper Division)';
    if (val >= 3.00) return 'Second Class (Lower Division)';
    if (val >= 2.00) return 'General Degree (Pass)';
    return 'Fail / Incomplete';
  }

  Map<int, double> get sgpaBySemester {
    final Map<int, double> sgpaMap = {};
    final semesters = _results.map((e) => e.semester).toSet();
    for (var s in semesters) {
      final sResults = _results.where((e) => e.semester == s);
      double qp = 0;
      int c = 0;
      for (var r in sResults) {
        qp += r.gpa * r.credits;
        c += r.credits;
      }
      sgpaMap[s] = c == 0 ? 0.0 : qp / c;
    }
    return sgpaMap;
  }

  // Static grading logic
  static String calculateGrade(int marks) {
    if (marks >= 75) return 'A+';
    if (marks >= 70) return 'A';
    if (marks >= 65) return 'A-';
    if (marks >= 60) return 'B+';
    if (marks >= 55) return 'B';
    if (marks >= 50) return 'B-';
    if (marks >= 45) return 'C+';
    if (marks >= 40) return 'C';
    if (marks >= 35) return 'C-';
    if (marks >= 30) return 'D+';
    if (marks >= 25) return 'D';
    return 'E';
  }

  static double calculateGpa(int marks) {
    if (marks >= 75) return 4.0;
    if (marks >= 70) return 4.0;
    if (marks >= 65) return 3.7;
    if (marks >= 60) return 3.3;
    if (marks >= 55) return 3.0;
    if (marks >= 50) return 2.7;
    if (marks >= 45) return 2.3;
    if (marks >= 40) return 2.0;
    if (marks >= 35) return 1.7;
    if (marks >= 30) return 1.3;
    if (marks >= 25) return 1.0;
    return 0.0;
  }

  Future<void> loadUserResults(String userId) async {
    _isLoading = true;
    notifyListeners();
    _results = await _dao.getResultsForUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllResults() async {
    _isLoading = true;
    notifyListeners();
    _results = await _dao.getAllResults();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addResult(AcademicResult result) async {
    await _dao.insertResult(result);
    await loadUserResults(result.userId);
  }

  Future<void> updateResult(AcademicResult result) async {
    await _dao.updateResult(result);
    await loadUserResults(result.userId);
  }

  Future<void> deleteResult(int id, String userId) async {
    await _dao.deleteResult(id);
    await loadUserResults(userId);
  }
}
