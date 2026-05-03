// =============================================================================
// providers/campus_contact_provider.dart
// =============================================================================

import 'package:flutter/material.dart';
import '../domain/models/campus_contact.dart';
import '../data/local/campus_contact_dao.dart';

class CampusContactProvider extends ChangeNotifier {
  final CampusContactDao _dao = CampusContactDao();

  List<CampusContact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CampusContact> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadContacts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _contacts = await _dao.getAllContacts();
    } catch (e) {
      _errorMessage = 'Failed to load contacts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(CampusContact contact) async {
    try {
      await _dao.insertContact(contact);
      await loadContacts();
    } catch (e) {
      _errorMessage = 'Failed to add contact: $e';
      notifyListeners();
    }
  }

  Future<void> updateContact(CampusContact contact) async {
    try {
      await _dao.updateContact(contact);
      await loadContacts();
    } catch (e) {
      _errorMessage = 'Failed to update contact: $e';
      notifyListeners();
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _dao.deleteContact(id);
      await loadContacts();
    } catch (e) {
      _errorMessage = 'Failed to delete contact: $e';
      notifyListeners();
    }
  }
}
