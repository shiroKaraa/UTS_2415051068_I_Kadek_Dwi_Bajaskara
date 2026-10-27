import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_type_enum.dart';

class AniListService {
  static const String _url = 'https://graphql.anilist.co';

  static const String _fields = '''
    id
    idMal
    title { romaji english native }
    coverImage { large }
    averageScore
    episodes
    chapters
    format
    status
    genres
    seasonYear
    description
  ''';

  Future<List<Map<String, dynamic>>> _query(
    String query,
    Map<String, dynamic> variables,
  ) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'query': query, 'variables': variables}),
    );

    if (response.statusCode == 429) {
      throw Exception('Terlalu banyak permintaan. Coba lagi sebentar.');
    }
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data (HTTP ${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['errors'] != null) {
      throw Exception('AniList error: ${body['errors'][0]['message']}');
    }

    final media = body['data']['Page']['media'] as List<dynamic>? ?? [];
    return media.cast<Map<String, dynamic>>();
  }

  String _type(JenisMedia jenis) =>
      jenis == JenisMedia.anime ? 'ANIME' : 'MANGA';

  String? _country(JenisMedia jenis) {
    switch (jenis) {
      case JenisMedia.anime:
        return 'JP'; 
      case JenisMedia.manhwa:
        return 'KR';
      case JenisMedia.manhua:
        return 'CN';
      case JenisMedia.manga:
        return 'JP';
      default:
        return null;
    }
  }

  Future<List<Map<String, dynamic>>> search({
    required String query,
    required JenisMedia jenis,
    int page = 1,
    String? genre,
    int? tahun,
  }) {
    const gql = '''
      query (\$page: Int, \$perPage: Int, \$search: String, \$type: MediaType, \$country: CountryCode, \$genre: String, \$seasonYear: Int) {
        Page(page: \$page, perPage: \$perPage) {
          media(search: \$search, type: \$type, countryOfOrigin: \$country, isAdult: false, genre: \$genre, seasonYear: \$seasonYear) {
            $_fields
          }
        }
      }
    ''';
    return _query(gql, {
      'page': page,
      'perPage': 20,
      'search': query,
      'type': _type(jenis),
      'country': _country(jenis),
      'genre': genre,
      'seasonYear': tahun,
    });
  }

  Future<List<Map<String, dynamic>>> getTop({
    required JenisMedia jenis,
    int page = 1,
    String? genre,
    int? tahun,
  }) {
    const gql = '''
      query (\$page: Int, \$perPage: Int, \$type: MediaType, \$country: CountryCode, \$genre: String, \$seasonYear: Int) {
        Page(page: \$page, perPage: \$perPage) {
          media(type: \$type, countryOfOrigin: \$country, sort: SCORE_DESC, isAdult: false, genre: \$genre, seasonYear: \$seasonYear) {
            $_fields
          }
        }
      }
    ''';
    return _query(gql, {
      'page': page,
      'perPage': 20,
      'type': _type(jenis),
      'country': _country(jenis),
      'genre': genre,
      'seasonYear': tahun,
    });
  }
}