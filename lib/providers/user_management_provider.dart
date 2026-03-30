import 'package:flutter/material.dart';
import '../domain/models/user.dart';
import '../data/local/user_dao.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserDao _dao = UserDao();

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _dao.getAllUsers();
    } catch (e) {
      _errorMessage = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(User user) async {
    await _dao.insertUser(user);
    await loadUsers();
  }

  Future<void> updateUser(User user) async {
    await _dao.updateUser(user);
    await loadUsers();
  }

  Future<void> deleteUser(String id) async {
    await _dao.deleteUser(id);
    await loadUsers();
  }

  Future<void> toggleSuspension(String id, bool suspend) async {
    await _dao.suspendUser(id, suspend);
    await loadUsers();
  }
}
