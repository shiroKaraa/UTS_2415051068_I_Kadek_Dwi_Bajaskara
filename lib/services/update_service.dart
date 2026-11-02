import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/update_info.dart';

class UpdateService {
  static const String _owner = 'shiroKaraa';
  static const String _repo = 'UTS_2415051068_I_Kadek_Dwi_Bajaskara';

  Future<UpdateInfo?> checkForUpdate() async {
    if (Platform.isIOS) return null;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'Tsuzuki-App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final updateInfo = UpdateInfo.fromGitHub(json);

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewer(updateInfo.version, currentVersion)) {
        return updateInfo;
      }
      return null;
    } catch (e) {
      debugPrint('Check update error: $e');
      return null;
    }
  }

  bool _isNewer(String remote, String current) {
    try {
      final r = remote.split('.').map(int.parse).toList();
      final c = current.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final rv = i < r.length ? r[i] : 0;
        final cv = i < c.length ? c[i] : 0;
        if (rv > cv) return true;
        if (rv < cv) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<File> downloadApk(
    UpdateInfo info, {
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/tsuzuki_update.apk';

    final existing = File(filePath);
    if (await existing.exists()) {
      await existing.delete();
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
    ));
    
    await dio.download(
      info.apkUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress?.call(received / total);
        }
      },
      options: Options(
        headers: {'User-Agent': 'Tsuzuki-App'},
        followRedirects: true,
      ),
    );

    return File(filePath);
  }
}