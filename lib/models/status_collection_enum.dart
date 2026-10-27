import 'media_type_enum.dart';

enum StatusKoleksi {
  direncanakan,
  sedang,
  selesai,
  ditunda,
  dihentikan;

  String label(JenisMedia jenis) {
    switch (this) {
      case StatusKoleksi.direncanakan:
        return 'Direncanakan';
      case StatusKoleksi.sedang:
        return jenis == JenisMedia.anime ? 'Sedang Menonton' : 'Sedang Membaca';
      case StatusKoleksi.selesai:
        return 'Selesai';
      case StatusKoleksi.ditunda:
        return 'Ditunda';
      case StatusKoleksi.dihentikan:
        return 'Dihentikan';
    }
  }
  String get netralLabel {
    switch (this) {
      case StatusKoleksi.direncanakan:
        return 'Direncanakan';
      case StatusKoleksi.sedang:
        return 'Sedang';
      case StatusKoleksi.selesai:
        return 'Selesai';
      case StatusKoleksi.ditunda:
        return 'Ditunda';
      case StatusKoleksi.dihentikan:
        return 'Dihentikan';
    }
  }

  String get value {
    return name;
  }

  static StatusKoleksi fromString(String value) {
    return StatusKoleksi.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StatusKoleksi.direncanakan,
    );
  }
}