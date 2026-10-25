import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistent_device_id/persistent_device_id.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default gelap
  String _deviceId = 'Memuat ID...';
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  String get deviceId => _deviceId;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString('theme_mode');
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.dark;
    }

    try {
      final persistentId = await PersistentDeviceId.getDeviceId();
      if (persistentId != null && persistentId.isNotEmpty) {
        _deviceId = persistentId;
      } else {
        _deviceId = 'ID tidak tersedia';
      }
    } catch (e) {
      debugPrint('Gagal mendapatkan ID perangkat: $e');
      _deviceId = 'Gagal memuat ID';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String modeString = 'dark';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.system) modeString = 'system';
    await prefs.setString('theme_mode', modeString);
  }
}