// =============================================================================
// providers/module_provider.dart
// =============================================================================

import 'package:flutter/material.dart';
import '../domain/models/module.dart';
import '../data/local/module_dao.dart';

class ModuleProvider extends ChangeNotifier {
  final ModuleDao _dao;

  ModuleProvider({ModuleDao? dao}) : _dao = dao ?? ModuleDao();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Module> _allModules = [];
  List<Module> get allModules => _allModules;

  List<Module> _enrolledModules = [];
  List<Module> get enrolledModules => _enrolledModules;

  Future<void> loadModules(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allModules = await _dao.getAllModules();
      _enrolledModules = await _dao.getEnrolledModules(userId);
    } catch (e) {
      debugPrint('[ModuleProvider] Failed to load modules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isEnrolled(String moduleId) {
    return _enrolledModules.any((m) => m.id == moduleId);
  }

  Future<void> enroll(String userId, String moduleId) async {
    await _dao.enrollModule(userId, moduleId);
    await loadModules(userId); // Reload state
  }

  Future<void> drop(String userId, String moduleId) async {
    await _dao.dropModule(userId, moduleId);
    await loadModules(userId); // Reload state
  }
}
