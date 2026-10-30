import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistent_device_id/persistent_device_id.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; 
  String? _deviceId;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  Locale _locale = const Locale('id'); 
  
  // State Baru
  bool _limitImageCache = false;
  bool _enableNsfw = false;

  ThemeMode get themeMode => _themeMode;
  String? get deviceId => _deviceId;
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  Locale get locale => _locale;
  bool get limitImageCache => _limitImageCache;
  bool get enableNsfw => _enableNsfw;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.dark;
      }

      _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final savedLang = prefs.getString('language_code');
      if (savedLang != null) {
        _locale = Locale(savedLang);
      }
      
      _limitImageCache = prefs.getBool('limit_image_cache') ?? false;
      _enableNsfw = prefs.getBool('enable_nsfw') ?? false;
    } catch (e) {
      debugPrint('Gagal memuat settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    try {
      final persistentId = await PersistentDeviceId.getDeviceId();
      if (persistentId != null && persistentId.isNotEmpty) {
        _deviceId = persistentId;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal memuat device ID: $e');
    }
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

  Future<void> setHasSeenOnboarding(bool value) async {
    _hasSeenOnboarding = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', value);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  Future<void> setLimitImageCache(bool value) async {
    _limitImageCache = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('limit_image_cache', value);
  }

  Future<void> setEnableNsfw(bool value) async {
    _enableNsfw = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_nsfw', value);
  }
}