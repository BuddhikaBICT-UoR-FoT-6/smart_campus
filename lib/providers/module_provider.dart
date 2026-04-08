// =============================================================================
// This file acts as the state controller for the Academic Portal's course
// registration system. It manages the global catalog of university modules, tracks
// which specific modules the active student has enrolled in, and handles the
//database transactions for enrolling or dropping a course.
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

  List<Module> getModulesByLevelAndSemester(int level, int semester) {
    return _allModules.where((m) => m.level == level && m.semester == semester).toList();
  }

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

  Future<void> loadAllModulesOnly() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allModules = await _dao.getAllModules();
    } catch (e) {
      debugPrint('[ModuleProvider] Failed to load all modules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isEnrolled(String moduleId) {
    return _enrolledModules.any((m) => m.id == moduleId);
  }

  Future<void> enroll(String userId, String moduleId, bool isLocked) async {
    if (isLocked) {
      debugPrint('[ModuleProvider] Blocked enrollment: Deadline passed.');
      return;
    }
    await _dao.enrollModule(userId, moduleId);
    await loadModules(userId); // Reload state
  }

  Future<void> drop(String userId, String moduleId, bool isLocked) async {
    if (isLocked) {
      debugPrint('[ModuleProvider] Blocked drop: Deadline passed.');
      return;
    }
    await _dao.dropModule(userId, moduleId);
    await loadModules(userId); // Reload state
  }

  Future<void> addModule(Module module) async {
    await _dao.insertModule(module);
    _allModules = await _dao.getAllModules();
    notifyListeners();
  }

  Future<void> deleteModule(String moduleId) async {
    await _dao.deleteModule(moduleId);
    _allModules = await _dao.getAllModules();
    notifyListeners();
  }
}
