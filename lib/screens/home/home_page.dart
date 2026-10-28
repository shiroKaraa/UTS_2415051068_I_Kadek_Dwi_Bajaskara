import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/catalog_item.dart';
import '../../models/profile_stats.dart';
import '../../models/collection_entry.dart';
import '../../models/status_collection_enum.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/media_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../catalog/catalog_detail_page.dart';
import '../collection/collection_detail_page.dart';
import '../collection/collection_page.dart';

class HomePage extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomePage({super.key, this.onNavigateTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _claimChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    if (auth.isAuthenticated && !_claimChecked) {
      _claimChecked = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _maybeOfferClaim();
      });
    } else if (!auth.isAuthenticated) {
      _claimChecked = false;
    }
  }

  Future<void> _maybeOfferClaim() async {
    final auth = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();
    final collection = context.read<CollectionProvider>();

    final deviceId = settings.deviceId;
    if (!auth.isAuthenticated || deviceId == null || deviceId.isEmpty || collection.isOffline) return;

    final count = await collection.countClaimableCollections(deviceId);
    if (count <= 0 || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.claimTitle),
        content: Text(l10n.claimDesc(count, auth.username ?? '-')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: Text(l10n.claimBtn)),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final claimed = await collection.claimDeviceCollections(deviceId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(claimed > 0 ? l10n.claimSuccess(claimed) : l10n.claimFailed)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.claimFailed), backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  Future<void> _onRefresh() async {
    final catalog = context.read<CatalogProvider>();
    final collection = context.read<CollectionProvider>();
    
    await Future.wait([
      collection.refresh(),
      catalog.fetchPopularHome(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOffline = context.select<CollectionProvider, bool>((c) => c.isOffline);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CatalogProvider>().fetchPopularHome();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            tooltip: l10n.navCatalog,
            onPressed: () => widget.onNavigateTab?.call(1),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isOffline)
            Container(
              width: double.infinity,
              color: AppColors.goldPrimary.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: 16, color: AppColors.goldPrimary),
                  const SizedBox(width: 8),
                  Text(l10n.offlineBanner, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          Expanded(
            child: RepaintBoundary(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: RefreshIndicator(
                    key: _refreshKey,
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSizes.spacingM),
                      children: [
                        const _WelcomeHeader(),
                        const SizedBox(height: AppSizes.spacingL),
                        const _ContinueSection(),
                        const SizedBox(height: AppSizes.spacingL),
                        const _StatsRow(),
                        const SizedBox(height: AppSizes.spacingL),
                        _PopularSection(
                          title: l10n.popularAnime,
                          isAnime: true,
                          onNavigateTab: widget.onNavigateTab,
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        _PopularSection(
                          title: l10n.popularManga,
                          isAnime: false,
                          onNavigateTab: widget.onNavigateTab,
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    final hour = DateTime.now().hour;
    String greeting = l10n.greetingEvening;
    if (hour < 12) greeting = l10n.greetingMorning;
    if (hour >= 12 && hour < 18) greeting = l10n.greetingAfternoon;

    final displayName = auth.displayName ?? auth.username ?? 'Pengguna';
    final avatar = auth.avatarEmoji ?? '👤';

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
          child: Text(avatar, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: AppSizes.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $displayName 👋',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                l10n.greetingSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final stats = context.select<CollectionProvider, ProfileStats>((c) => c.stats);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        _StatCard(title: l10n.statTotal, value: stats.totalEntries, icon: Icons.collections_bookmark, color: AppColors.infoBlue),
        const SizedBox(width: AppSizes.spacingS),
        _StatCard(title: l10n.statReading, value: stats.totalOngoing, icon: Icons.play_circle_outline, color: AppColors.primaryGreen),
        const SizedBox(width: AppSizes.spacingS),
        _StatCard(title: l10n.statCompleted, value: stats.totalCompleted, icon: Icons.check_circle_outline, color: AppColors.goldPrimary),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingM, horizontal: AppSizes.spacingS),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppSizes.spacingS),
              Text('$value', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(title, style: Theme.of(context).textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueSection extends StatefulWidget {
  const _ContinueSection();

  @override
  State<_ContinueSection> createState() => _ContinueSectionState();
}

class _ContinueSectionState extends State<_ContinueSection> {
  final Set<int> _processingIds = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = context.select<CollectionProvider, List<EntriKoleksi>>((c) => c.continueWatching);

    if (items.isEmpty) {
      return Card(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            children: [
              Icon(Icons.play_circle_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: AppSizes.spacingM),
              Text(l10n.noTrackedYet, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.spacingS),
              Text(l10n.searchFirst, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.continueWatching, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionPage())),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        ...items.map((e) {
          final progress = (e.total != null && e.total! > 0) ? (e.progres / e.total!).clamp(0.0, 1.0) : 0.0;
          final isProcessing = _processingIds.contains(e.id);

          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 40, height: 60, child: CoverImage(url: e.coverUrl)),
              ),
              title: Text(e.judul, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.progres} / ${e.total ?? "?"} ${e.jenis.satuanProgres(l10n)}'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: AppColors.primaryGreen,
                    minHeight: 4,
                  ),
                ],
              ),
              trailing: IconButton.filledTonal(
                icon: isProcessing 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add),
                onPressed: (e.total != null && e.progres >= e.total!) || isProcessing
                    ? null
                    : () => _handleIncrement(e),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CollectionDetailPage(entri: e))),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _handleIncrement(EntriKoleksi e) async {
    setState(() => _processingIds.add(e.id!));

    final provider = context.read<CollectionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final updated = await provider.incrementProgressAndReturn(e);

    if (!mounted) return;
    setState(() => _processingIds.remove(e.id));

    if (updated == null) {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Gagal menambah progres.')));
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    if (updated.status == StatusKoleksi.selesai) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.congratsCompleted)));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.progressAdded)));
    }
  }
}

class _PopularSection extends StatelessWidget {
  final String title;
  final bool isAnime;
  final Function(int)? onNavigateTab;

  const _PopularSection({required this.title, required this.isAnime, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final items = context.select<CatalogProvider, List<ItemKatalog>>(
      (c) => isAnime ? c.topAnime : c.topManga,
    );
    final isLoading = context.select<CatalogProvider, bool>((c) => c.isLoadingPopular);

    const cardWidth = 130.0;
    const aspectRatio = 2 / 3;
    const imageHeight = cardWidth / aspectRatio;
    const textHeight = 60.0;
    final listHeight = imageHeight + textHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => onNavigateTab?.call(1),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (isLoading && items.isEmpty)
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: AppSizes.spacingM),
                child: ShimmerLoading(width: 130, height: 200),
              ),
            ),
          )
        else if (items.isEmpty)
          const EmptyView(title: 'Belum Ada Data', subtitle: 'Data populer tidak dapat dimuat.', icon: Icons.inbox_outlined)
        else
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.spacingM),
                  child: SizedBox(
                    width: cardWidth,
                    child: MediaCard(
                      item: item,
                      width: cardWidth,
                      heroTag: 'home_${item.malId}',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogDetailPage(item: item))),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}