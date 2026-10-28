import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/media_type_enum.dart';
import '../providers/auth_provider.dart';
import '../providers/collection_provider.dart';
import 'profile/edit_profile_page.dart';
import 'favorites_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _konfirmasiLogout(BuildContext context, AppLocalizations l10n) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final collection = context.watch<CollectionProvider>();
    final theme = Theme.of(context);

    int totalAnime = 0;
    int totalEpisodes = 0;
    int totalManga = 0;
    int totalChapters = 0;

    for (var e in collection.allEntries) {
      if (e.jenis == JenisMedia.anime) {
        totalAnime++;
        totalEpisodes += e.progres;
      } else {
        totalManga++;
        totalChapters += e.progres;
      }
    }
    final double daysWatched = (totalEpisodes * 24.0) / (60 * 24);
    final int volumesRead = (totalChapters / 9).ceil();

    final displayName = auth.displayName ?? auth.username ?? 'Pengguna';
    final username = auth.username ?? '-';
    final avatar = auth.avatarEmoji ?? '👤';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
          Card(
            elevation: 0,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingL),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                    child: Text(avatar, style: const TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  Text(
                    displayName,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '@$username',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text('Statistik', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(context, 'Anime', totalAnime.toString(), Icons.play_circle_outline, AppColors.infoBlue),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: _buildStatCard(context, 'Manga', totalManga.toString(), Icons.menu_book_outlined, AppColors.typeManga),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(context, 'Days Watched', daysWatched.toStringAsFixed(1), Icons.access_time, AppColors.goldPrimary),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: _buildStatCard(context, 'Episodes', totalEpisodes.toString(), Icons.tv, AppColors.primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(context, 'Chapters Read', totalChapters.toString(), Icons.auto_stories, AppColors.typeAnime),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: _buildStatCard(context, 'Volumes Read', volumesRead.toString(), Icons.library_books, AppColors.typeManhwa),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          Card(
            elevation: 0,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text('Favorit Saya', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Lihat daftar anime & manga favoritmu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _konfirmasiLogout(context, l10n),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingXl),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSizes.spacingS),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}