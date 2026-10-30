import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../models/profile_stats.dart';
import '../../widgets/shimmer_loading.dart';
import 'edit_profile_page.dart';
import '../collection/favorites_page.dart';
import '../collection/collection_page.dart';
import '../settings/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<bool> _konfirmasiLogout(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.logoutTitle),
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
      body: RefreshIndicator(
        onRefresh: () => context.read<CollectionProvider>().refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _ProfileHeader(),
            
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (isEmpty && !isLoading)
                    _EmptyProfileState(onLihatKatalog: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionPage()));
                    })
                  else ...[
                    _SectionTitle(title: l10n.statistics, icon: Icons.insights_outlined),
                    const SizedBox(height: AppSizes.spacingS),
                    if (isLoading && isEmpty) 
                      const _ShimmerStats()
                    else 
                      _StatsSection(stats: stats),

                    const SizedBox(height: AppSizes.spacingL),
                    
                    const _QuickMenu(),
                  ],
                ]),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _LogoutButton(
                    onConfirm: () => _konfirmasiLogout(context, l10n),
                    onSignOut: () => context.read<AuthProvider>().signOut(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final displayName = context.select<AuthProvider, String?>((a) => a.displayName);
    final username = context.select<AuthProvider, String?>((a) => a.username);
    final avatar = context.select<AuthProvider, String?>((a) => a.avatarEmoji);
    
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final name = displayName ?? username ?? 'Pengguna';
    final avatarEmoji = avatar ?? '👤';

    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(l10n.profile, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGreen.withValues(alpha: 0.35),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Semantics(
                        button: true,
                        label: l10n.editProfile,
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryGreen.withValues(alpha: 0.2),
                              border: Border.all(color: AppColors.primaryGreen, width: 3),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: theme.cardColor,
                                  child: Text(avatarEmoji, style: const TextStyle(fontSize: 32)),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, size: 16, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.greeting(name),
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@${username ?? '-'}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _QuickMenu extends StatelessWidget {
  const _QuickMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _QuickMenuCard(
            icon: Icons.favorite,
            color: AppColors.typeManga,
            title: l10n.favoriteTitle,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesPage())),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: _QuickMenuCard(
            icon: Icons.settings,
            color: AppColors.typeManhua,
            title: l10n.settings,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ),
      ],
    );
  }
}

class _QuickMenuCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _QuickMenuCard({required this.icon, required this.color, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
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
    final l10n = AppLocalizations.of(context)!;
    final showAnime = stats.totalAnime > 0;
    final showManga = stats.totalManga > 0;
    final total = stats.totalAnime + stats.totalManga;
    final animePercent = total > 0 ? (stats.totalAnime / total * 100).round() : 0;
    final mangaPercent = total > 0 ? (stats.totalManga / total * 100).round() : 0;
    final secondaryItems = <Widget>[
      if (showAnime)
        _StatSecondaryCard(
          title: l10n.statDaysWatched,
          value: stats.daysWatched.toStringAsFixed(1),
          icon: Icons.access_time,
        ),
      if (showAnime)
        _StatSecondaryCard(
          title: l10n.statEpisodes,
          value: stats.totalEpisodes.toString(),
          icon: Icons.tv,
        ),
      if (showManga)
        _StatSecondaryCard(
          title: l10n.statChapters,
          value: stats.totalChapters.toString(),
          icon: Icons.auto_stories,
        ),
      if (showManga)
        _StatSecondaryCard(
          title: l10n.statVolumes,
          value: stats.volumesRead.toString(),
          icon: Icons.library_books,
        ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatHighlightCard(
                title: 'Anime',
                value: stats.totalAnime,
                icon: Icons.play_circle_outline,
                color: AppColors.infoBlue,
              ),
            ),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(
              child: _StatHighlightCard(
                title: 'Manga',
                value: stats.totalManga,
                icon: Icons.menu_book_outlined,
                color: AppColors.typeManga,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (total > 0) ...[
          _RatioBar(anime: stats.totalAnime, manga: stats.totalManga),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showAnime)
                _LegendItem(
                  color: AppColors.infoBlue,
                  label: l10n.animeLegend(animePercent),
                ),
              if (showManga)
                _LegendItem(
                  color: AppColors.typeManga,
                  label: l10n.mangaLegend(mangaPercent),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
        ],
        if (secondaryItems.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppSizes.spacingS;
              final itemWidth = (constraints.maxWidth - spacing) / 2;
              final rows = <Widget>[];
              for (var i = 0; i < secondaryItems.length; i += 2) {
                final left = secondaryItems[i];
                final right = i + 1 < secondaryItems.length
                    ? secondaryItems[i + 1]
                    : const SizedBox.shrink();
                rows.add(
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: itemWidth, child: left),
                      const SizedBox(width: spacing),
                      SizedBox(width: itemWidth, child: right),
                    ],
                  ),
                );
                if (i + 2 < secondaryItems.length) {
                  rows.add(const SizedBox(height: spacing));
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              );
            },
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
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
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: BorderSide(color: color.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingM),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: AppSizes.spacingS),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: value),
                duration: const Duration(milliseconds: 800),
                builder: (context, val, child) => Text('$val', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
              ),
              Text(title, style: Theme.of(context).textTheme.labelSmall),
            ],
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

  const _StatSecondaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$title: $value',
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingS),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerStats extends StatelessWidget {
  const _ShimmerStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: ShimmerLoading(height: 100)),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(child: ShimmerLoading(height: 100)),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        ShimmerLoading(height: 8),
        const SizedBox(height: AppSizes.spacingS),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSizes.spacingS,
          crossAxisSpacing: AppSizes.spacingS,
          childAspectRatio: 2.8,
          children: const [
            ShimmerLoading(), ShimmerLoading(), ShimmerLoading(), ShimmerLoading(),
          ],
        ),
      ],
    );
  }
}

class _EmptyProfileState extends StatelessWidget {
  final VoidCallback onLihatKatalog;
  const _EmptyProfileState({required this.onLihatKatalog});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingXl),
        child: Column(
          children: [
            Icon(Icons.collections_bookmark_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSizes.spacingM),
            Text(l10n.emptyCollection,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.spacingS),
            Text(l10n.emptyCollectionPrompt,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSizes.spacingL),
            ElevatedButton(
              onPressed: onLihatKatalog,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.black),
              child: Text(l10n.searchNow),
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
    
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      await widget.onSignOut();
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.logoutFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleLogout,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
        label: Text(
          _isLoading ? l10n.processing : l10n.logoutConfirmBtn,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}