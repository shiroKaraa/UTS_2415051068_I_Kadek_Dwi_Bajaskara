class LabelKustom {
  final int? id;
  final String userId;
  final String nama;
  final String warna;

  LabelKustom({
    this.id,
    required this.userId,
    required this.nama,
    this.warna = '#5FCB97',
  });

  factory LabelKustom.fromJson(Map<String, dynamic> json) {
    return LabelKustom(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      nama: json['nama'] as String,
      warna: json['warna'] as String? ?? '#5FCB97',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'warna': warna,
    };
  }

  LabelKustom copyWith({
    int? id,
    String? userId,
    String? nama,
    String? warna,
  }) {
    return LabelKustom(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      warna: warna ?? this.warna,
    );
  }
}