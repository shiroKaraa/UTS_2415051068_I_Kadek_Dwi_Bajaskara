class LabelKustom {
  final int? id;
  final String userId;
  final String nama;
  final String satuanProgres;

  LabelKustom({
    this.id,
    required this.userId,
    required this.nama,
    this.satuanProgres = 'Bagian',
  });

  factory LabelKustom.fromJson(Map<String, dynamic> json) {
    return LabelKustom(
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

  LabelKustom copyWith({
    int? id,
    String? userId,
    String? nama,
    String? satuanProgres,
  }) {
    return LabelKustom(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      satuanProgres: satuanProgres ?? this.satuanProgres,
    );
  }
}