class KategoriKustom {
  final int? id;
  final String userId;
  final String nama;
  final String satuanProgres;

  KategoriKustom({
    this.id,
    required this.userId,
    required this.nama,
    this.satuanProgres = 'Bagian',
  });

  factory KategoriKustom.fromJson(Map<String, dynamic> json) {
    return KategoriKustom(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      nama: json['nama'] as String,
      satuanProgres: json['satuan_progres'] as String? ?? 'Bagian',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'satuan_progres': satuanProgres,
    };
  }

  KategoriKustom copyWith({
    int? id,
    String? userId,
    String? nama,
    String? satuanProgres,
  }) {
    return KategoriKustom(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      satuanProgres: satuanProgres ?? this.satuanProgres,
    );
  }
}