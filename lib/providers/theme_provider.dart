import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // 临时注释

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  // Load theme mode from preferences - 临时禁用
  Future<void> _loadThemeMode() async {
    // final prefs = await SharedPreferences.getInstance();
    // final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    
    // _themeMode = ThemeMode.values[themeModeIndex];
    _themeMode = ThemeMode.light; // 默认浅色主题
    notifyListeners();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    
    // Save to preferences - 临时禁用
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt('theme_mode', mode.index);
    
    notifyListeners();
  }
}