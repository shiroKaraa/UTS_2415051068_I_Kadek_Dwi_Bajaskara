class KategoriKustom {
  final int? id;
  final String deviceId;
  final String nama;
  final String satuanProgres;

  KategoriKustom({
    this.id,
    required this.deviceId,
    required this.nama,
    this.satuanProgres = 'Bagian',
  });

  factory KategoriKustom.fromJson(Map<String, dynamic> json) {
    return KategoriKustom(
      id: json['id'] as int?,
      deviceId: json['device_id'] as String,
      nama: json['nama'] as String,
      satuanProgres: json['satuan_progres'] as String? ?? 'Bagian',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'nama': nama,
      'satuan_progres': satuanProgres,
    };
  }

  KategoriKustom copyWith({
    int? id,
    String? deviceId,
    String? nama,
    String? satuanProgres,
  }) {
    return KategoriKustom(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      nama: nama ?? this.nama,
      satuanProgres: satuanProgres ?? this.satuanProgres,
    );
  }
}