// =============================================================================
// providers/lms_provider.dart
// =============================================================================

import 'package:flutter/material.dart';
import '../domain/models/lms_material.dart';
import '../data/local/lms_dao.dart';

class LmsProvider extends ChangeNotifier {
  final LmsDao _dao;

  LmsProvider({LmsDao? dao}) : _dao = dao ?? LmsDao();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<LmsMaterial> _materials = [];
  List<LmsMaterial> get materials => _materials;

  Future<void> loadMaterialsForModule(String moduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _materials = await _dao.getMaterialsForModule(moduleId);
    } catch (e) {
      debugPrint('[LmsProvider] Failed to load materials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _materials = [];
    notifyListeners();
  }

  Future<void> addMaterial(LmsMaterial material) async {
    await _dao.insertMaterial(material);
    await loadMaterialsForModule(material.moduleId);
  }
}
