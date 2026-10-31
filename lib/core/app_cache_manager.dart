import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCacheManager {
  AppCacheManager._();

  static const key = 'tsuzukiImageCache';
  static CacheManager? _instance;

  static Future<CacheManager> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    final limit = prefs.getBool('limit_image_cache') ?? false;
    _instance = CacheManager(Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: limit ? 500 : 2000,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ));
    return _instance!;
  }

  static Future<void> refresh() async {
    _instance = null;
    await getInstance();
  }
}