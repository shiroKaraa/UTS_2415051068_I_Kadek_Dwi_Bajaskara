import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static const String _cachePrefix = 'tr_id_v2_';
  static const String _indexKey = 'tr_id_v2_index';
  static const int _maxEntries = 50;
  static const Duration _timeout = Duration(seconds: 10);

  Future<String> translateToId(String text, {int? anilistId}) async {
    if (text.trim().isEmpty) return text;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = anilistId != null
        ? '$_cachePrefix$anilistId'
        : '${_cachePrefix}hash_${text.hashCode}';

    final cached = prefs.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final obj = jsonDecode(cached) as Map<String, dynamic>;
        final t = obj['text'] as String?;
        if (t != null && t.isNotEmpty) return t;
      } catch (_) {
        return cached;
      }
    }

    try {
      final translated = await _fetchTranslation(text);
      if (translated.isNotEmpty && translated != text) {
        await _putCache(prefs, cacheKey, translated);
      }
      return translated.isEmpty ? text : translated;
    } catch (_) {
      return text;
    }
  }

  Future<void> _putCache(
      SharedPreferences prefs, String key, String value) async {
    await prefs.setString(
      key,
      jsonEncode({'ts': DateTime.now().toIso8601String(), 'text': value}),
    );

    final rawIndex = prefs.getString(_indexKey);
    List<Map<String, dynamic>> index = [];
    if (rawIndex != null) {
      try {
        index = (jsonDecode(rawIndex) as List<dynamic>)
            .cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    index.removeWhere((e) => e['key'] == key);
    index.add({'key': key, 'ts': DateTime.now().toIso8601String()});

    if (index.length > _maxEntries) {
      index.sort((a, b) => (a['ts'] as String).compareTo(b['ts'] as String));
      final removed = index.take(index.length - _maxEntries).toList();
      for (final r in removed) {
        await prefs.remove(r['key'] as String);
      }
      index = index.skip(index.length - _maxEntries).toList();
    }

    await prefs.setString(_indexKey, jsonEncode(index));
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
    final indexRaw = prefs.getString(_indexKey);
    if (indexRaw != null) {
      try {
        final index = (jsonDecode(indexRaw) as List<dynamic>)
            .cast<Map<String, dynamic>>();
        for (final e in index) {
          await prefs.remove(e['key'] as String);
        }
      } catch (_) {}
    }
    await prefs.remove(_indexKey);

    final oldKeys = prefs
        .getKeys()
        .where((k) => k.startsWith('tr_id_') && !k.startsWith(_cachePrefix))
        .toList();
    for (final k in oldKeys) {
      await prefs.remove(k);
    }
  }
}