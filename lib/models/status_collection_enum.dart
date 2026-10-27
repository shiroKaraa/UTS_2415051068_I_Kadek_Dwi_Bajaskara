import '../l10n/app_localizations.dart';
import 'media_type_enum.dart';

enum StatusKoleksi {
  direncanakan,
  sedang,
  selesai,
  ditunda,
  dihentikan;

  String label(JenisMedia jenis, [AppLocalizations? l10n]) {
    switch (this) {
      case StatusKoleksi.direncanakan:
        return l10n?.activeFilter ?? 'Direncanakan';
      case StatusKoleksi.sedang:
        if (jenis == JenisMedia.anime) {
          return l10n?.statReading ?? 'Sedang Menonton';
        }
        return l10n?.statReading ?? 'Sedang Membaca';
      case StatusKoleksi.selesai:
        return l10n?.statCompleted ?? 'Selesai';
      case StatusKoleksi.ditunda:
        return l10n?.system ?? 'Ditunda';
      case StatusKoleksi.dihentikan:
        return l10n?.delete ?? 'Dihentikan'; 
    }
  }
  
  String netralLabel([AppLocalizations? l10n]) {
    switch (this) {
      case StatusKoleksi.direncanakan:
        return l10n?.activeFilter ?? 'Direncanakan';
      case StatusKoleksi.sedang:
        return l10n?.statReading ?? 'Sedang';
      case StatusKoleksi.selesai:
        return l10n?.statCompleted ?? 'Selesai';
      case StatusKoleksi.ditunda:
        return l10n?.system ?? 'Ditunda';
      case StatusKoleksi.dihentikan:
        return l10n?.delete ?? 'Dihentikan';
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