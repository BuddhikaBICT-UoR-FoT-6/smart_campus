import 'package:flutter/material.dart';
import '../domain/models/medical_submission.dart';
import '../data/local/medical_dao.dart';

class MedicalProvider extends ChangeNotifier {
  final MedicalDao _dao = MedicalDao();

  List<MedicalSubmission> _submissions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicalSubmission> get submissions => List.unmodifiable(_submissions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllSubmissions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _submissions = await _dao.getAllSubmissions();
    } catch (e) {
      _errorMessage = 'Failed to load medical submissions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubmissionsForUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _submissions = await _dao.getSubmissionsForUser(userId);
    } catch (e) {
      _errorMessage = 'Failed to load medical submissions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSubmission(MedicalSubmission submission) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dao.insertSubmission(submission);
      _submissions = await _dao.getSubmissionsForUser(submission.userId);
    } catch (e) {
      _errorMessage = 'Failed to add submission: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveSubmission(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dao.updateSubmissionStatus(id, 'approved');
      _submissions = await _dao.getAllSubmissions();
    } catch (e) {
      _errorMessage = 'Failed to approve submission: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectSubmission(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dao.updateSubmissionStatus(id, 'rejected');
      _submissions = await _dao.getAllSubmissions();
    } catch (e) {
      _errorMessage = 'Failed to reject submission: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
