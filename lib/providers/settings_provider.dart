import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistent_device_id/persistent_device_id.dart';
import '../models/card_size_enum.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String? _deviceId;
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  Locale _locale = const Locale('id');
  bool _limitImageCache = false;
  bool _enableNsfw = false;
  CardSize _cardSize = CardSize.medium;
  int _itemsPerRow = 3;
  bool _isListView = false;

  ThemeMode get themeMode => _themeMode;
  String? get deviceId => _deviceId;
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  Locale get locale => _locale;
  bool get limitImageCache => _limitImageCache;
  bool get enableNsfw => _enableNsfw;
  int get itemsPerRow => _itemsPerRow;
  bool get isListView => _isListView;
  CardSize get cardSize => _cardSize;

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

      final savedCardSize = prefs.getString('card_size');
      _cardSize = CardSize.values.firstWhere(
        (e) => e.name == savedCardSize,
        orElse: () => CardSize.medium,
      );
      _itemsPerRow = prefs.getInt('items_per_row') ?? 3;
      _isListView = prefs.getBool('is_list_view') ?? false;
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

  Future<void> setCardSize(CardSize size) async {
    if (_cardSize == size) return;
    _cardSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('card_size', size.name);
  }

  Future<void> setItemsPerRow(int value) async {
    final clamped = value.clamp(2, 6);
    if (_itemsPerRow == clamped) return;
    _itemsPerRow = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('items_per_row', clamped);
  }

  Future<void> setListView(bool value) async {
    if (_isListView == value) return;
    _isListView = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_list_view', value);
  }
}