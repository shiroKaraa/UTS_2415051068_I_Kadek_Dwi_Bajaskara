import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/media_type_enum.dart';

class RateLimitException implements Exception {}
class NetworkException implements Exception {}
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class AniListResult {
  final List<Map<String, dynamic>> media;
  final bool hasNextPage;
  final int total;

  AniListResult({required this.media, required this.hasNextPage, required this.total});
}

class AniListService {
  static const String _url = 'https://graphql.anilist.co';
  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 15);

  static const String _fields = '''
    id
    idMal
    title { romaji english native }
    coverImage { large extraLarge }
    bannerImage
    averageScore
    episodes
    chapters
    format
    status
    genres
    seasonYear
    startDate { year }
    description
    duration
    popularity
    studios(isMain: true) { nodes { name } }
    trailer { id site }
    nextAiringEpisode { episode }
  ''';

  Future<AniListResult> _query(String query, Map<String, dynamic> variables) async {
    try {
      final response = await _client.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'query': query, 'variables': variables}),
      ).timeout(_timeout);

      if (response.statusCode == 429) throw RateLimitException();
      if (response.statusCode != 200) {
        debugPrint('AniList Error Body: ${response.body}');
        throw ApiException('HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['errors'] != null) {
        debugPrint('AniList GraphQL Error: ${body['errors']}');
        throw ApiException('AniList: ${body['errors'][0]['message']}');
      }

      final pageData = body['data']['Page'];
      final media = (pageData['media'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      final pageInfo = pageData['pageInfo'] as Map<String, dynamic>? ?? {};
      
      return AniListResult(
        media: media,
        hasNextPage: pageInfo['hasNextPage'] as bool? ?? false,
        total: pageInfo['total'] as int? ?? 0,
      );
    } on TimeoutException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on FormatException {
      throw ApiException('Format respons tidak valid');
    } on TypeError {
      throw ApiException('Format respons tidak valid');
    } catch (e) {
      if (e is RateLimitException || e is ApiException || e is NetworkException) rethrow;
      throw NetworkException();
    }
  }

  String _type(JenisMedia jenis) => (jenis == JenisMedia.anime) ? 'ANIME' : 'MANGA';

  String? _country(JenisMedia jenis) {
    switch (jenis) {
      case JenisMedia.anime: return 'JP';
      case JenisMedia.manhwa: return 'KR';
      case JenisMedia.manhua: return 'CN';
      case JenisMedia.manga: return 'JP';
      default: return null;
    }
  }

  List<String>? _format(JenisMedia jenis) {
    if (jenis == JenisMedia.manga) return ['MANGA', 'ONE_SHOT'];
    return null;
  }

  Future<AniListResult> fetchPage({
    required JenisMedia jenis,
    int page = 1,
    String? searchQuery,
    List<String>? genres,
    int? tahun,
    String? status,
    String sort = 'POPULARITY_DESC',
  }) async {
    const gql = '''
      query (\$page: Int, \$perPage: Int, \$type: MediaType, \$country: CountryCode, \$sort: [MediaSort], \$search: String, \$genre_in: [String], \$startGreater: FuzzyDateInt, \$startLesser: FuzzyDateInt, \$status: MediaStatus, \$format_in: [MediaFormat]) {
        Page(page: \$page, perPage: \$perPage) {
          pageInfo { hasNextPage total }
          media(type: \$type, countryOfOrigin: \$country, isAdult: false, sort: \$sort, search: \$search, genre_in: \$genre_in, startDate_greater: \$startGreater, startDate_lesser: \$startLesser, status: \$status, format_in: \$format_in) {
            $_fields
          }
        }
      }
    ''';

    final vars = <String, dynamic>{
      'page': page,
      'perPage': 20,
      'type': _type(jenis),
      'country': _country(jenis),
      'sort': [sort],
    };

    if (searchQuery != null && searchQuery.isNotEmpty) vars['search'] = searchQuery;
    if (genres != null && genres.isNotEmpty) vars['genre_in'] = genres;
    if (status != null && status.isNotEmpty) vars['status'] = status;
    if (_format(jenis) != null) vars['format_in'] = _format(jenis);

    if (tahun != null) {
      vars['startGreater'] = (tahun * 10000) - 1;
      vars['startLesser'] = (tahun + 1) * 10000;
    }

    return _query(gql, vars);
  }

  Future<List<String>> fetchGenres() async {
    const gql = 'query { GenreCollection }';
    try {
      final response = await _client.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': gql}),
      ).timeout(_timeout);

      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body);
      final genres = (body['data']['GenreCollection'] as List<dynamic>?)?.cast<String>() ?? [];
      return genres.where((g) => g != 'Hentai').toList();
    } catch (_) {
      return [];
    }
  }

  void dispose() => _client.close();
}