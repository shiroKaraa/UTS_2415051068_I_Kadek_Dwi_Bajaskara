import 'media_type_enum.dart';

class ItemKatalog {
  final int malId;
  final String judul;
  final String? judulInggris;
  final String? coverUrl;
  final String? sinopsis;
  final double? skor;
  final int? total;
  final JenisMedia jenis;
  
  // Field Baru
  final List<String> genres;
  final int? tahunRilis;
  final String? statusTayang;

  ItemKatalog({
    required this.malId,
    required this.judul,
    this.judulInggris,
    this.coverUrl,
    this.sinopsis,
    this.skor,
    this.total,
    required this.jenis,
    this.genres = const [],
    this.tahunRilis,
    this.statusTayang,
  });

  String get displayTitle {
    if (judulInggris != null && judulInggris!.isNotEmpty) {
      return judulInggris!;
    }
    return judul;
  }

  factory ItemKatalog.fromAniList(Map<String, dynamic> json, JenisMedia jenis) {
    final titleObj = json['title'] as Map<String, dynamic>?;
    final coverObj = json['coverImage'] as Map<String, dynamic>?;
    
    final malId = json['idMal'] as int? ?? json['id'] as int;

    int? totalData;
    if (jenis == JenisMedia.anime) {
      totalData = json['episodes'] as int?;
    } else {
      totalData = json['chapters'] as int?;
    }

    double? skor;
    if (json['averageScore'] != null) {
      skor = (json['averageScore'] as num).toDouble() / 10.0;
    }

    // Parsing field baru
    final genresList = (json['genres'] as List<dynamic>?)?.cast<String>() ?? [];

    return ItemKatalog(
      malId: malId,
      judul: titleObj?['romaji'] as String? ?? 'Tanpa Judul',
      judulInggris: titleObj?['english'] as String?,
      coverUrl: coverObj?['large'] as String?,
      sinopsis: json['description'] as String?,
      skor: skor,
      total: totalData,
      jenis: jenis,
      genres: genresList,
      tahunRilis: json['seasonYear'] as int?,
      statusTayang: json['status'] as String?,
    );
  }
}