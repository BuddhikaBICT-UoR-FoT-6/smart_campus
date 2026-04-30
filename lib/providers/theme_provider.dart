// =============================================================================
// providers/theme_provider.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _themeKey = 'user_theme_preference';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Loads the saved theme preference from secure storage.
  Future<void> loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeProvider] Error loading theme: $e');
    }
  }

  /// Toggles the theme and persists the choice.
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    try {
      await _storage.write(key: _themeKey, value: isDark ? 'dark' : 'light');
    } catch (e) {
      debugPrint('[ThemeProvider] Error saving theme: $e');
    }
  }

  /// Resets to system default and persists.
  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;
    notifyListeners();
    
    try {
      await _storage.delete(key: _themeKey);
    } catch (e) {
      debugPrint('[ThemeProvider] Error clearing theme: $e');
    }
  }
}
