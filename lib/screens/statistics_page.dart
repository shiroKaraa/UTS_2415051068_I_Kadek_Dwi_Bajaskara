import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/media_type_enum.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();
    final entries = collection.allEntries;
    int totalAnime = 0;
    int totalManga = 0;
    int totalEpisodesWatch = 0;
    int totalChaptersRead = 0;
    int totalSelesai = 0;

    for (var e in entries) {
      if (e.status == StatusKoleksi.selesai) totalSelesai++;

      if (e.jenis == JenisMedia.anime) {
        totalAnime++;
        totalEpisodesWatch += e.progres;
      } else {
        totalManga++;
        totalChaptersRead += e.progres;
      }
    }

    final double totalMenitAnime = totalEpisodesWatch * 24.0;
    final double daysWatch = totalMenitAnime / (60 * 24);
    final int volumesRead = (totalChaptersRead / 9).ceil();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Perpustakaan')),
      body: entries.isEmpty
          ? const Center(child: Text('Belum ada data untuk ditampilkan.'))
          : ListView(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Total Judul',
                        entries.length.toString(),
                        Icons.collections_bookmark,
                        AppColors.infoBlue,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Selesai',
                        totalSelesai.toString(),
                        Icons.check_circle,
                        AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingM),
                _buildWideSummaryCard(
                  context,
                  'Estimasi Waktu Menonton',
                  '${daysWatch.toStringAsFixed(1)} Hari',
                  Icons.access_time,
                  AppColors.primaryGreen,
                ),

                const SizedBox(height: AppSizes.spacingL),
                Text(
                  'Rincian Aktivitas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.play_circle_outline, color: AppColors.typeAnime),
                    title: const Text('Anime'),
                    subtitle: Text('$totalAnime Judul dilacak'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$totalEpisodesWatch', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Episode', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: AppColors.typeManga),
                    title: const Text('Manga / Komik'),
                    subtitle: Text('$totalManga Judul dilacak'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$totalChaptersRead', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Chapter', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.auto_stories, color: AppColors.primaryGreen),
                    title: const Text('Estimasi Volume'),
                    subtitle: const Text('Berdasarkan rasio 9 Chapter/Volume'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$volumesRead', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Volume', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spacingL),
                const Center(
                  child: Text(
                    'Catatan: Estimasi waktu menonton dihitung dari 1 episode = 24 menit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSizes.spacingS),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildWideSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: AppSizes.spacingM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}