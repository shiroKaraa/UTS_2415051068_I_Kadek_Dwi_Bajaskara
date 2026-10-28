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

    int anime = 0, episodes = 0, manga = 0, chapters = 0, completed = 0, ongoing = 0;
    const double avgEpisodeMinutes = 24.0;

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

    final days = (episodes * avgEpisodeMinutes) / 1440;
    final volumes = (chapters / 9).floor();

    return ProfileStats(
      totalAnime: anime,
      totalEpisodes: episodes,
      daysWatched: days,
      totalManga: manga,
      totalChapters: chapters,
      volumesRead: volumes > 0 ? volumes : (chapters > 0 ? 1 : 0),
      totalCompleted: completed,
      totalOngoing: ongoing,
      totalEntries: entries.length,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileStats &&
          runtimeType == other.runtimeType &&
          totalAnime == other.totalAnime &&
          totalEpisodes == other.totalEpisodes &&
          daysWatched == other.daysWatched &&
          totalManga == other.totalManga &&
          totalChapters == other.totalChapters &&
          volumesRead == other.volumesRead &&
          totalCompleted == other.totalCompleted &&
          totalOngoing == other.totalOngoing &&
          totalEntries == other.totalEntries;

  @override
  int get hashCode =>
      totalAnime.hashCode ^
      totalEpisodes.hashCode ^
      daysWatched.hashCode ^
      totalManga.hashCode ^
      totalChapters.hashCode ^
      volumesRead.hashCode ^
      totalCompleted.hashCode ^
      totalOngoing.hashCode ^
      totalEntries.hashCode;
  
    String get formattedWatchTime {
    if (totalEpisodes == 0) return '0m';
    final totalMinutes = totalEpisodes * 24;
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) return '${hours}j';
    return '${hours}j ${minutes}m';
  }

  String get userLevel {
    if (totalEpisodes < 50) return 'beginner';
    if (totalEpisodes < 200) return 'intermediate';
    return 'veteran';
  }
  
}