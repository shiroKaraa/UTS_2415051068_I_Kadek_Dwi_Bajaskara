import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/profile_stats.dart';
import '../../providers/collection_provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.select<CollectionProvider, ProfileStats>((c) => c.stats);
    final isEmpty = context.select<CollectionProvider, bool>((c) => c.allEntries.isEmpty);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: isEmpty
          ? Center(child: Text(l10n.errorEmptyData))
          : ListView(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        l10n.totalTitles,
                        stats.totalEntries.toString(),
                        Icons.collections_bookmark,
                        AppColors.infoBlue,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        l10n.completed,
                        stats.totalCompleted.toString(),
                        Icons.check_circle,
                        AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingM),
                _buildWideSummaryCard(
                  context,
                  l10n.estimatedTime,
                  '${stats.daysWatched.toStringAsFixed(1)} ${l10n.days}',
                  Icons.access_time,
                  AppColors.primaryGreen,
                ),
                const SizedBox(height: AppSizes.spacingL),
                Text(
                  l10n.activityDetails,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.play_circle_outline, color: AppColors.typeAnime),
                    title: Text(l10n.anime),
                    subtitle: Text(l10n.trackedTitles(stats.totalAnime)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${stats.totalEpisodes}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(l10n.episodes, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: AppColors.typeManga),
                    title: Text(l10n.manga),
                    subtitle: Text(l10n.trackedTitles(stats.totalManga)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${stats.totalChapters}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(l10n.chapters, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.auto_stories, color: AppColors.primaryGreen),
                    title: Text(l10n.estimatedVolumes),
                    subtitle: Text(l10n.volumeRatio),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${stats.volumesRead}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(l10n.volumes, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingL),
                Center(
                  child: Text(
                    l10n.statsNote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
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

  Widget _buildWideSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
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