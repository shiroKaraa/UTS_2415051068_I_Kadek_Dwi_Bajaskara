import 'media_type_enum.dart';
import 'status_collection_enum.dart';

class EntriKoleksi {
  final int? id;
  final String? userId;
  final String? deviceId;
  final JenisMedia jenis;
  final int? kategoriId;
  final String? externalId;
  final String judul;
  final String? coverUrl;
  final StatusKoleksi status;
  final int progres;
  final int? total;
  final int? rating;
  final String? catatan;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EntriKoleksi({
    this.id,
    this.userId,
    this.deviceId,
    required this.jenis,
    this.kategoriId,
    this.externalId,
    required this.judul,
    this.coverUrl,
    required this.status,
    this.progres = 0,
    this.total,
    this.rating,
    this.catatan,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
  });

  factory EntriKoleksi.fromJson(Map<String, dynamic> json) {
    return EntriKoleksi(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      deviceId: json['device_id'] as String?,
      jenis: JenisMedia.values.firstWhere(
        (e) => e.name == json['jenis'],
        orElse: () => JenisMedia.lainnya,
      ),
      kategoriId: json['kategori_id'] as int?,
      externalId: json['external_id'] as String?,
      judul: json['judul'] as String,
      coverUrl: json['cover_url'] as String?,
      status: StatusKoleksi.fromString(json['status'] as String),
      progres: json['progres'] as int? ?? 0,
      total: json['total'] as int?,
      rating: json['rating'] as int?,
      catatan: json['catatan'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'jenis': jenis.name,
      'kategori_id': kategoriId,
      'external_id': externalId,
      'judul': judul,
      'cover_url': coverUrl,
      'status': status.name,
      'progres': progres,
      'total': total,
      'rating': rating,
      'catatan': catatan,
      'is_favorite': isFavorite,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toBackupJson() {
    return {
      'user_id': userId,
      'device_id': deviceId,
      'jenis': jenis.name,
      'kategori_id': kategoriId,
      'external_id': externalId,
      'judul': judul,
      'cover_url': coverUrl,
      'status': status.name,
      'progres': progres,
      'total': total,
      'rating': rating,
      'catatan': catatan,
      'is_favorite': isFavorite,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  EntriKoleksi copyWith({
    int? id,
    String? userId,
    String? deviceId,
    JenisMedia? jenis,
    int? kategoriId,
    String? externalId,
    String? judul,
    String? coverUrl,
    StatusKoleksi? status,
    int? progres,
    int? total,
    int? rating,
    String? catatan,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EntriKoleksi(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      jenis: jenis ?? this.jenis,
      kategoriId: kategoriId ?? this.kategoriId,
      externalId: externalId ?? this.externalId,
      judul: judul ?? this.judul,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      progres: progres ?? this.progres,
      total: total ?? this.total,
      rating: rating ?? this.rating,
      catatan: catatan ?? this.catatan,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}