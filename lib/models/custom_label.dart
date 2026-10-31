class LabelKustom {
  final int? id;
  final String userId;
  final String nama;

  LabelKustom({
    this.id,
    required this.userId,
    required this.nama,
  });

  factory LabelKustom.fromJson(Map<String, dynamic> json) {
    return LabelKustom(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      nama: json['nama'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
    };
  }

  LabelKustom copyWith({
    int? id,
    String? userId,
    String? nama,
  }) {
    return LabelKustom(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
    );
  }
}