import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
  }
}
