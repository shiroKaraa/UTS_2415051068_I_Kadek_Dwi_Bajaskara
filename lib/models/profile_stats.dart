import 'collection_entry.dart';
import 'media_type_enum.dart';
import 'status_collection_enum.dart';

class ProfileStats {
  final int totalAnime;
  final int totalEpisodes;
  final double daysWatched;
  final int totalManga;
  final int totalChapters;
  final int volumesRead;
  final int totalCompleted;
  final int totalOngoing;
  final int totalEntries;
  static const int _avgEpisodeMinutes = 24;
  static const int _chaptersPerVolume = 9;

  const ProfileStats({
    this.totalAnime = 0,
    this.totalEpisodes = 0,
    this.daysWatched = 0.0,
    this.totalManga = 0,
    this.totalChapters = 0,
    this.volumesRead = 0,
    this.totalCompleted = 0,
    this.totalOngoing = 0,
    this.totalEntries = 0,
  });

  factory ProfileStats.fromEntries(List<EntriKoleksi> entries) {
    if (entries.isEmpty) return const ProfileStats();

    int anime = 0;
    int episodes = 0;
    int manga = 0;
    int chapters = 0;
    int completed = 0;
    int ongoing = 0;

    for (var e in entries) {
      if (e.status == StatusKoleksi.selesai) completed++;
      if (e.status == StatusKoleksi.sedang) ongoing++;

      switch (e.jenis) {
        case JenisMedia.anime:
          anime++;
          episodes += e.progres;
          break;
        case JenisMedia.manga:
        case JenisMedia.manhwa:
        case JenisMedia.manhua:
          manga++;
          chapters += e.progres;
          break;
        default:
          break;
      }
    }

    final volumes = (chapters / _chaptersPerVolume).floor();
    return ProfileStats(
      totalAnime: anime,
      totalEpisodes: episodes,
      daysWatched: (episodes * _avgEpisodeMinutes) / 1440,
      totalManga: manga,
      totalChapters: chapters,
      volumesRead: volumes,
      totalCompleted: completed,
      totalOngoing: ongoing,
      totalEntries: entries.length,
    );
  }

  String get formattedWatchTime {
    if (totalEpisodes == 0) return '0m';
    final totalMinutes = totalEpisodes * _avgEpisodeMinutes;
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) return '${hours}j';
    return '${hours}j ${minutes}m';
  }

  String get userLevel {
    final score = totalEpisodes + (totalChapters ~/ 10);
    if (score < 50) return 'beginner';
    if (score < 200) return 'intermediate';
    return 'veteran';
  }
}