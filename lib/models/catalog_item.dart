import 'media_type_enum.dart';

class ItemKatalog {
  final int anilistId;
  final int? malId;
  final String judul;
  final String? judulInggris;
  final String? judulNative;
  final List<String> synonyms;
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
  final bool isAdult;

  ItemKatalog({
    required this.anilistId,
    this.malId,
    required this.judul,
    this.judulInggris,
    this.judulNative,
    this.synonyms = const [],
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
    this.isAdult = false,
  });

  String get displayTitle {
    if (judulInggris != null && judulInggris!.isNotEmpty) {
      return judulInggris!;
    }
    return judul;
  }

  List<MapEntry<String, String>> get alternativeTitles {
    final out = <MapEntry<String, String>>[];
    final seen = <String>{displayTitle.toLowerCase()};

    void add(String label, String? value) {
      if (value == null) return;
      final v = value.trim();
      if (v.isEmpty) return;
      if (!seen.add(v.toLowerCase())) return;
      out.add(MapEntry(label, v));
    }

    add('Romaji', judul);
    add('English', judulInggris);
    add('Native', judulNative);
    for (final s in synonyms) {
      add('Sinonim', s);
    }
    return out;
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

    final rawSynonyms = json['synonyms'] as List<dynamic>?;

    return ItemKatalog(
      anilistId: json['id'] as int,
      malId: json['idMal'] as int?,
      judul: titleObj?['romaji'] as String? ?? 'Tanpa Judul',
      judulInggris: titleObj?['english'] as String?,
      judulNative: titleObj?['native'] as String?,
      synonyms: rawSynonyms?.cast<String>() ?? const [],
      coverUrl:
          coverObj?['large'] as String? ?? coverObj?['extraLarge'] as String?,
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
      isAdult: json['isAdult'] as bool? ?? false,
    );
  }
}