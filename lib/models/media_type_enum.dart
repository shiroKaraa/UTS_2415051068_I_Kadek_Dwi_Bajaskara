import '../l10n/app_localizations.dart';

enum JenisMedia {
  anime,
  manga,
  manhwa,
  manhua,
  lainnya;

  String label([AppLocalizations? l10n]) {
    switch (this) {
      case JenisMedia.anime:
        return l10n?.anime ?? 'Anime';
      case JenisMedia.manga:
        return 'Manga';
      case JenisMedia.manhwa:
        return 'Manhwa';
      case JenisMedia.manhua:
        return 'Manhua';
      case JenisMedia.lainnya:
        return l10n?.about ?? 'Lainnya'; 
    }
  }

  String satuanProgres([AppLocalizations? l10n]) {
    if (this == JenisMedia.anime) return l10n?.episodes ?? 'Episode';
    return l10n?.chapters ?? 'Chapter';
  }
}