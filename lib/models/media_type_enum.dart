enum JenisMedia {
  anime,
  manga,
  manhwa,
  manhua,
  lainnya;

  String get label {
    switch (this) {
      case JenisMedia.anime:
        return 'Anime';
      case JenisMedia.manga:
        return 'Manga';
      case JenisMedia.manhwa:
        return 'Manhwa';
      case JenisMedia.manhua:
        return 'Manhua';
      case JenisMedia.lainnya:
        return 'Lainnya';
    }
  }

  String get satuanProgres {
    if (this == JenisMedia.anime) return 'Episode';
    return 'Chapter';
  }
}