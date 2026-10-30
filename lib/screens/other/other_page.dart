import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/profile_stats.dart';
import '../../models/status_collection_enum.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/settings_provider.dart';
import '../collection/collection_page.dart';
import '../info/about_page.dart';
import '../settings/category_page.dart';
import '../info/help_page.dart';
import '../settings/settings_page.dart';
import '../info/statistics_page.dart';
import '../settings/storage_page.dart';

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = context.select<CollectionProvider, ProfileStats>((c) => c.stats);
    final isOffline = context.select<CollectionProvider, bool>((c) => c.isOffline);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _OtherHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingXl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isOffline)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off, color: AppColors.goldPrimary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(l10n.offlineMode,
                                style: const TextStyle(fontSize: 12)),
                          ),
                          TextButton(
                            onPressed: () async {
                              final provider = context.read<CollectionProvider>();
                              final messenger = ScaffoldMessenger.of(context);
                              final ok = await provider.retryConnection();
                              if (!context.mounted) return;
                              messenger.showSnackBar(SnackBar(
                                content: Text(ok ? l10n.reconnected : l10n.stillOffline),
                              ));
                            },
                            child: Text(l10n.retryConnection,
                                style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),

                _SectionTitle(title: l10n.activityDetails, icon: Icons.insights_outlined),
                const SizedBox(height: AppSizes.spacingS),
                _ActivityStats(stats: stats),
                const SizedBox(height: AppSizes.spacingL),

                _SectionTitle(title: l10n.navOther, icon: Icons.dashboard_outlined),
                const SizedBox(height: AppSizes.spacingS),
                _ManageGrid(),
                const SizedBox(height: AppSizes.spacingL),

                _SectionTitle(title: l10n.settings, icon: Icons.settings_outlined),
                const SizedBox(height: AppSizes.spacingS),
                _SettingsTile(),
                const SizedBox(height: AppSizes.spacingL),

                _SectionTitle(title: l10n.help, icon: Icons.help_outline),
                const SizedBox(height: AppSizes.spacingS),
                _OthersList(),
                const SizedBox(height: AppSizes.spacingXl),
                _Footer(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SliverAppBar(
      pinned: true, 
      expandedHeight: 140, 
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        title: Text(l10n.navOther, style: const TextStyle(fontSize: 16)),
        background: Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                child: Text(auth.avatarEmoji ?? '👤', style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.displayName ?? auth.username ?? 'Pengguna',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '@${auth.username ?? '-'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityStats extends StatelessWidget {
  final ProfileStats stats;
  const _ActivityStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.collections_bookmark,
          label: AppLocalizations.of(context)!.statTotal,
          value: stats.totalEntries,
          color: AppColors.infoBlue,
          onTap: () => _navigateToFiltered(context, null),
        ),
        const SizedBox(width: AppSizes.spacingS),
        _StatCard(
          icon: Icons.play_circle_outline,
          label: AppLocalizations.of(context)!.statReading,
          value: stats.totalOngoing,
          color: AppColors.primaryGreen,
          onTap: () => _navigateToFiltered(context, StatusKoleksi.sedang),
        ),
        const SizedBox(width: AppSizes.spacingS),
        _StatCard(
          icon: Icons.check_circle_outline,
          label: AppLocalizations.of(context)!.statCompleted,
          value: stats.totalCompleted,
          color: AppColors.goldPrimary,
          onTap: () => _navigateToFiltered(context, StatusKoleksi.selesai),
        ),
      ],
    );
  }

  void _navigateToFiltered(BuildContext context, StatusKoleksi? status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionPage(initialStatus: status),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: '$label: $value',
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 8),
                  Text('$value', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(label, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _LinkTile(
          icon: Icons.insights_outlined,
          title: l10n.statistics,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsPage())),
        ),
        _LinkTile(
          icon: Icons.label_outline,
          title: l10n.manageCategories,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryPage())),
        ),
        _LinkTile(
          icon: Icons.storage_outlined,
          title: l10n.storage,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoragePage())),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    final themeLabel = settings.themeMode == ThemeMode.dark
        ? l10n.dark
        : settings.themeMode == ThemeMode.light
            ? l10n.light
            : l10n.system;
    final langLabel = settings.locale.languageCode.toUpperCase();
    final nsfwLabel = settings.enableNsfw ? ' · NSFW ON' : '';

    return _LinkTile(
      icon: Icons.settings_outlined,
      title: l10n.settings,
      subtitle: '$themeLabel · $langLabel$nsfwLabel',
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SettingsPage())),
    );
  }
}

class _OthersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _LinkTile(
          icon: Icons.favorite_border,
          title: l10n.supportUs,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.supportThankYou)),
            );
          },
        ),
        _LinkTile(
          icon: Icons.help_outline,
          title: l10n.helpFaq,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage())),
        ),
        _LinkTile(
          icon: Icons.info_outline,
          title: l10n.aboutApp,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _LinkTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: subtitle != null ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall) : null,
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
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

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.auto_stories, size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text('© 2026 Tsuzuki App', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}