import 'package:flutter/material.dart';
import '../domain/models/academic_result.dart';
import '../data/local/result_dao.dart';

class ResultsProvider extends ChangeNotifier {
  final ResultDao _dao = ResultDao();

  List<AcademicResult> _results = [];
  bool _isLoading = false;

  List<AcademicResult> get results => _results;
  bool get isLoading => _isLoading;

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
    await loadAllResults();
  }

  Future<void> updateResult(AcademicResult result) async {
    await _dao.updateResult(result);
    await loadAllResults();
  }

  Future<void> deleteResult(int id) async {
    await _dao.deleteResult(id);
    await loadAllResults();
  }
}
