import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../providers/auth_provider.dart';
import '../providers/collection_provider.dart';
import '../models/profile_stats.dart';
import 'profile/edit_profile_page.dart';
import 'favorites_page.dart';
import 'collection_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  Future<bool> _konfirmasiLogout(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.logoutConfirmDesc),
        content: Text(l10n.logoutConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(dialogCtx).colorScheme.error),
            child: Text(l10n.logoutConfirmBtn),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.select<CollectionProvider, ProfileStats>((c) => c.stats);
    final isLoading = context.select<CollectionProvider, bool>((c) => c.isLoading);
    final isEmpty = context.select<CollectionProvider, bool>((c) => c.allEntries.isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<CollectionProvider>().refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.spacingM),
          children: [
            _ProfileHeader(stats: stats),
            const SizedBox(height: AppSizes.spacingL),
            
            if (isEmpty && !isLoading)
              _EmptyProfileState(onLihatKatalog: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionPage()));
              })
            else ...[
              Text(l10n.statistics, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.spacingS),
              
              if (isLoading && isEmpty) 
                const Center(child: CircularProgressIndicator())
              else 
                _StatsSection(stats: stats),

              const SizedBox(height: AppSizes.spacingL),
              
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: AppColors.typeManga),
                  title: Text(l10n.favoriteTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage())),
                ),
              ),
            ],
            
            const SizedBox(height: AppSizes.spacingXl),
            
            _LogoutButton(
              onConfirm: () => _konfirmasiLogout(context, l10n),
              onSignOut: () => context.read<AuthProvider>().signOut(),
            ),
            const SizedBox(height: AppSizes.spacingL),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileStats stats;
  const _ProfileHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final displayName = auth.displayName ?? auth.username ?? 'Pengguna';
    final username = auth.username ?? '-';
    final avatar = auth.avatarEmoji ?? '👤';

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          gradient: LinearGradient(
            colors: [theme.cardColor, AppColors.primaryGreen.withValues(alpha: 0.25)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: theme.cardColor,
                    child: Text(avatar, style: const TextStyle(fontSize: 44)),
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 16, color: Colors.black),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                    tooltip: 'Edit Profil',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(displayName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('@$username', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSizes.spacingS),
            Text(
              '${stats.totalAnime} Anime · ${stats.totalManga} Manga',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final ProfileStats stats;
  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatHighlightCard(title: 'Anime', value: stats.totalAnime, icon: Icons.play_circle_outline, color: AppColors.infoBlue)),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(child: _StatHighlightCard(title: 'Manga', value: stats.totalManga, icon: Icons.menu_book_outlined, color: AppColors.typeManga)),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        _RatioBar(anime: stats.totalAnime, manga: stats.totalManga),
        const SizedBox(height: AppSizes.spacingS),
        Wrap(
          spacing: AppSizes.spacingS,
          runSpacing: AppSizes.spacingS,
          children: [
            _StatSecondaryCard(title: 'Days Watched', value: stats.daysWatched.toStringAsFixed(1), icon: Icons.access_time),
            _StatSecondaryCard(title: 'Episodes', value: stats.totalEpisodes.toString(), icon: Icons.tv),
            _StatSecondaryCard(title: 'Chapters Read', value: stats.totalChapters.toString(), icon: Icons.auto_stories),
            _StatSecondaryCard(title: 'Volumes', value: stats.volumesRead.toString(), icon: Icons.library_books),
          ],
        ),
      ],
    );
  }
}

class _RatioBar extends StatelessWidget {
  final int anime;
  final int manga;
  const _RatioBar({required this.anime, required this.manga});

  @override
  Widget build(BuildContext context) {
    if (anime == 0 && manga == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            if (anime > 0) Expanded(flex: anime, child: Container(color: AppColors.infoBlue)),
            if (manga > 0) Expanded(flex: manga, child: Container(color: AppColors.typeManga)),
          ],
        ),
      ),
    );
  }
}

class _StatHighlightCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatHighlightCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          onTap: () {
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: AppSizes.spacingS),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 800),
                  builder: (_, val, _) => Text('$val', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
                ),
                Text(title, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatSecondaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatSecondaryCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Container(
        width: (MediaQuery.sizeOf(context).width - AppSizes.spacingM * 2 - AppSizes.spacingS) / 2,
        padding: const EdgeInsets.all(AppSizes.spacingS),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(title, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProfileState extends StatelessWidget {
  final VoidCallback onLihatKatalog;
  const _EmptyProfileState({required this.onLihatKatalog});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingXl),
        child: Column(
          children: [
            Icon(Icons.collections_bookmark_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSizes.spacingM),
            Text('Koleksimu Masih Kosong', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.spacingS),
            Text('Mulai tambahkan anime pertamamu!', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSizes.spacingL),
            ElevatedButton(
              onPressed: onLihatKatalog,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.black),
              child: const Text('Cari Anime'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final Future<bool> Function() onConfirm;
  final Future<void> Function() onSignOut;

  const _LogoutButton({required this.onConfirm, required this.onSignOut});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final confirmed = await widget.onConfirm();
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      await widget.onSignOut();
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal keluar, coba lagi.'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleLogout,
        icon: _isLoading 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.logout),
        label: Text(_isLoading ? 'Memproses...' : 'Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}