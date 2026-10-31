import 'package:flutter_test/flutter_test.dart';
import 'package:tsuzuki/models/collection_entry.dart';
import 'package:tsuzuki/models/media_type_enum.dart';
import 'package:tsuzuki/models/profile_stats.dart';
import 'package:tsuzuki/models/status_collection_enum.dart';

void main() {
  group('ProfileStats.fromEntries', () {
    test('kosong → semua nol', () {
      final stats = ProfileStats.fromEntries([]);
      expect(stats.totalAnime, 0);
      expect(stats.totalEpisodes, 0);
      expect(stats.daysWatched, 0);
      expect(stats.totalManga, 0);
      expect(stats.totalChapters, 0);
      expect(stats.volumesRead, 0);
      expect(stats.totalCompleted, 0);
      expect(stats.totalOngoing, 0);
      expect(stats.totalEntries, 0);
    });

    test('hitung anime + episode', () {
      final entries = [
        EntriKoleksi(
          jenis: JenisMedia.anime,
          judul: 'Anime A',
          status: StatusKoleksi.selesai,
          progres: 24,
          total: 24,
        ),
        EntriKoleksi(
          jenis: JenisMedia.anime,
          judul: 'Anime B',
          status: StatusKoleksi.sedang,
          progres: 12,
          total: 24,
        ),
      ];
      final stats = ProfileStats.fromEntries(entries);
      expect(stats.totalAnime, 2);
      expect(stats.totalEpisodes, 36);
      expect(stats.totalCompleted, 1);
      expect(stats.totalOngoing, 1);
      expect(stats.totalEntries, 2);
    });

    test('hitung manga + chapter + volume', () {
      final entries = [
        EntriKoleksi(
          jenis: JenisMedia.manga,
          judul: 'Manga A',
          status: StatusKoleksi.sedang,
          progres: 90,
        ),
      ];
      final stats = ProfileStats.fromEntries(entries);
      expect(stats.totalManga, 1);
      expect(stats.totalChapters, 90);
      expect(stats.volumesRead, 10); // 90 / 9 = 10
    });

    test('hitungan hari (24 menit per episode)', () {
      final entries = [
        EntriKoleksi(
          jenis: JenisMedia.anime,
          judul: 'Anime C',
          status: StatusKoleksi.selesai,
          progres: 60, // 60 × 24 menit = 1440 menit = 1 hari
        ),
      ];
      final stats = ProfileStats.fromEntries(entries);
      expect(stats.daysWatched, 1.0);
    });
  });

  group('ProfileStats.formattedWatchTime', () {
    test('0 episode → 0m', () {
      const stats = ProfileStats();
      expect(stats.formattedWatchTime, '0m');
    });

    test('kurang dari 60 menit', () {
      const stats = ProfileStats(totalEpisodes: 2); // 48 menit
      expect(stats.formattedWatchTime, '48m');
    });

    test('lebih dari 1 jam (ada sisa menit)', () {
      const stats = ProfileStats(totalEpisodes: 3); // 72 menit
      expect(stats.formattedWatchTime, '1j 12m');
    });

    test('pas jam bulat (tanpa sisa menit)', () {
      const stats = ProfileStats(totalEpisodes: 5); // 120 menit
      expect(stats.formattedWatchTime, '2j');
    });
  });
}