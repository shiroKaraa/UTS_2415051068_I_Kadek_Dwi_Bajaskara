import 'media_type_enum.dart';
import 'status_collection_enum.dart';

class EntriKoleksi {
  final int? id;
  final String? userId;
  final String? deviceId;
  final JenisMedia jenis;
  final int? labelId;
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
    this.labelId,
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
      labelId: json['label_id'] as int?,
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

  Map<String, dynamic> toJson({bool touch = true}) {
    return {
      'device_id': deviceId,
      'jenis': jenis.name,
      'label_id': labelId,
      'external_id': externalId,
      'judul': judul,
      'cover_url': coverUrl,
      'status': status.name,
      'progres': progres,
      'total': total,
      'rating': rating,
      'catatan': catatan,
      'is_favorite': isFavorite,
      if (touch) 'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'jenis': jenis.name,
      'label_id': labelId,
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

  Map<String, dynamic> toBackupJson() {
    return {
      'user_id': userId,
      'device_id': deviceId,
      'jenis': jenis.name,
      'label_id': labelId,
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
    bool clearId = false,
    int? id,
    String? userId,
    String? deviceId,
    JenisMedia? jenis,
    bool clearLabelId = false,
    int? labelId,
    bool clearExternalId = false,
    String? externalId,
    String? judul,
    bool clearCoverUrl = false,
    String? coverUrl,
    StatusKoleksi? status,
    int? progres,
    bool clearTotal = false,
    int? total,
    bool clearRating = false,
    int? rating,
    bool clearCatatan = false,
    String? catatan,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EntriKoleksi(
      id: clearId ? null : (id ?? this.id),
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      jenis: jenis ?? this.jenis,
      labelId: clearLabelId ? null : (labelId ?? this.labelId),
      externalId: clearExternalId ? null : (externalId ?? this.externalId),
      judul: judul ?? this.judul,
      coverUrl: clearCoverUrl ? null : (coverUrl ?? this.coverUrl),
      status: status ?? this.status,
      progres: progres ?? this.progres,
      total: clearTotal ? null : (total ?? this.total),
      rating: clearRating ? null : (rating ?? this.rating),
      catatan: clearCatatan ? null : (catatan ?? this.catatan),
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntriKoleksi &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          jenis == other.jenis &&
          externalId == other.externalId &&
          judul == other.judul &&
          status == other.status &&
          progres == other.progres &&
          total == other.total &&
          rating == other.rating &&
          catatan == other.catatan &&
          isFavorite == other.isFavorite &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      jenis.hashCode ^
      externalId.hashCode ^
      judul.hashCode ^
      status.hashCode ^
      progres.hashCode ^
      total.hashCode ^
      rating.hashCode ^
      catatan.hashCode ^
      isFavorite.hashCode ^
      updatedAt.hashCode;
}