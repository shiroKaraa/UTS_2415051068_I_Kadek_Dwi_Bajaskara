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

  ItemKatalog({
    required this.malId,
    required this.judul,
    this.judulInggris,
    this.coverUrl,
    this.sinopsis,
    this.skor,
    this.total,
    required this.jenis,
  });

  String get displayTitle {
    if (judulInggris != null && judulInggris!.isNotEmpty) {
      return judulInggris!;
    }
    return judul;
  }

  factory ItemKatalog.fromJikan(Map<String, dynamic> json, JenisMedia jenis) {
    String? cover;
    if (json['images'] != null && json['images']['jpg'] != null) {
      cover = json['images']['jpg']['image_url'] as String?;
    }

    int? totalData;
    if (jenis == JenisMedia.anime) {
      totalData = json['episodes'] as int?;
    } else {
      totalData = json['chapters'] as int?;
    }

    return ItemKatalog(
      malId: json['mal_id'] as int,
      judul: json['title'] as String? ?? 'Tanpa Judul',
      judulInggris: json['title_english'] as String?,
      coverUrl: cover,
      sinopsis: json['synopsis'] as String?,
      skor: (json['score'] as num?)?.toDouble(),
      total: totalData,
      jenis: jenis,
    );
  }
}