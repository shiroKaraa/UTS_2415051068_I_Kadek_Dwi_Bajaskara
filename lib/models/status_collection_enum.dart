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
        return l10n?.statusPlanned ?? 'Direncanakan';
      case StatusKoleksi.sedang:
        if (jenis == JenisMedia.anime) {
          return l10n?.statusOngoingWatch ?? 'Sedang Menonton';
        }
        return l10n?.statusOngoingRead ?? 'Sedang Membaca';
      case StatusKoleksi.selesai:
        return l10n?.statusCompleted ?? 'Selesai';
      case StatusKoleksi.ditunda:
        return l10n?.statusPaused ?? 'Ditunda';
      case StatusKoleksi.dihentikan:
        return l10n?.statusDropped ?? 'Dihentikan';
    }
  }

  String netralLabel([AppLocalizations? l10n]) {
    switch (this) {
      case StatusKoleksi.direncanakan:
        return l10n?.statusPlanned ?? 'Direncanakan';
      case StatusKoleksi.sedang:
        return l10n?.statusOngoing ?? 'Sedang';
      case StatusKoleksi.selesai:
        return l10n?.statusCompleted ?? 'Selesai';
      case StatusKoleksi.ditunda:
        return l10n?.statusPaused ?? 'Ditunda';
      case StatusKoleksi.dihentikan:
        return l10n?.statusDropped ?? 'Dihentikan';
    }
  }

  String get value => name;

  static StatusKoleksi fromString(String value) {
    return StatusKoleksi.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StatusKoleksi.direncanakan,
    );
  }
}