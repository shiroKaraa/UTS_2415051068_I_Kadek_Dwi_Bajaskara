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

    int totalProgres = 0;
    int totalSelesai = 0;
    final Map<JenisMedia, int> jumlahPerJenis = {};

    for (var e in entries) {
      totalProgres += e.progres;
      if (e.status == StatusKoleksi.selesai) totalSelesai++;
      jumlahPerJenis[e.jenis] = (jumlahPerJenis[e.jenis] ?? 0) + 1;
    }

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
                _buildSummaryCard(
                  context,
                  'Total Episode/Chapter Dilacak',
                  totalProgres.toString(),
                  Icons.play_arrow,
                  AppColors.primaryGreen,
                ),
                
                const SizedBox(height: AppSizes.spacingL),
                Text(
                  'Rincian per Jenis Media',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.spacingS),
                ...JenisMedia.values.map((jenis) {
                  final count = jumlahPerJenis[jenis] ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
                    child: ListTile(
                      leading: Icon(Icons.book, color: AppColors.typeAnime),
                      title: Text(jenis.label),
                      trailing: Text(
                        '$count Judul',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                }),
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
}