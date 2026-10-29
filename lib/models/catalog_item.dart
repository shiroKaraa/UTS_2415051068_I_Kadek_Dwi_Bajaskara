import 'media_type_enum.dart';

class ItemKatalog {
  final int anilistId;
  final int? malId;
  final String judul;
  final String? judulInggris;
  final String? coverUrl;
  final String? bannerUrl;
  final String? sinopsis;
  final double? skor;
  final int? total;
  final JenisMedia jenis;
  final List<String> genres;
  final int? tahunRilis;
  final String? statusTayang;
  final String? studio;
  final int? durasi;
  final int? popularitas;

  ItemKatalog({
    required this.anilistId,
    this.malId,
    required this.judul,
    this.judulInggris,
    this.coverUrl,
    this.bannerUrl,
    this.sinopsis,
    this.skor,
    this.total,
    required this.jenis,
    this.genres = const [],
    this.tahunRilis,
    this.statusTayang,
    this.studio,
    this.durasi,
    this.popularitas,
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
    final startDate = json['startDate'] as Map<String, dynamic>?;
    final studiosObj = json['studios'] as Map<String, dynamic>?;
    final studioNodes = studiosObj?['nodes'] as List<dynamic>?;

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

    return ItemKatalog(
      anilistId: json['id'] as int,
      malId: json['idMal'] as int?,
      judul: titleObj?['romaji'] as String? ?? 'Tanpa Judul',
      judulInggris: titleObj?['english'] as String?,
      coverUrl: coverObj?['large'] as String? ?? coverObj?['extraLarge'] as String?,
      bannerUrl: json['bannerImage'] as String?,
      sinopsis: json['description'] as String?,
      skor: skor,
      total: totalData,
      jenis: jenis,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      tahunRilis: startDate?['year'] as int? ?? json['seasonYear'] as int?,
      statusTayang: json['status'] as String?,
      studio: (studioNodes != null && studioNodes.isNotEmpty)
          ? (studioNodes[0]['name'] as String?)
          : null,
      durasi: json['duration'] as int?,
      popularitas: json['popularity'] as int?,
    );
  }
}