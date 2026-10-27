import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static const String _cachePrefix = 'tr_id_';
  static const Duration _timeout = Duration(seconds: 10);

  Future<String> translateToId(String text) async {
    if (text.trim().isEmpty) return text;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix${text.hashCode}';

    final cached = prefs.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final translated = await _fetchTranslation(text);
      if (translated.isNotEmpty && translated != text) {
        await prefs.setString(cacheKey, translated);
      }
      return translated.isEmpty ? text : translated;
    } catch (_) {
      return text;
    }
  }

  Future<String> _fetchTranslation(String text) async {
    final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single'
      '?client=gtx&sl=en&tl=id&dt=t&q=${Uri.encodeComponent(text)}',
    );

    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    final segments = (data[0] as List).cast<List<dynamic>>();
    final buffer = StringBuffer();
    for (final seg in segments) {
      if (seg.isNotEmpty && seg[0] is String) {
        buffer.write(seg[0]);
      }
    }
    return buffer.toString().trim();
  }
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_cachePrefix))
        .toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}