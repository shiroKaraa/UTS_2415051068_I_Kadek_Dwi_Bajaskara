import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/catalog_item.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import '../providers/catalog_provider.dart';
import '../widgets/cover_image.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/media_card.dart';
import '../widgets/shimmer_loading.dart';
import 'catalog_detail_page.dart';
import 'collection_detail_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onLihatKatalog;

  const HomePage({super.key, this.onLihatKatalog});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      catalog.fetchPopularHome();
    });
  }

  Future<void> _onRefresh() async {
    final messenger = ScaffoldMessenger.of(context);
    final catalog = context.read<CatalogProvider>();
    final collection = context.read<CollectionProvider>();

    try {
      await Future.wait([
        collection.refresh(),
        catalog.refresh(),
      ]);
    } catch (e) {
      debugPrint('Refresh error: $e');
    }

    if (!mounted) return;
    if (catalog.errorMessage != null && catalog.items.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(catalog.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final collection = context.watch<CollectionProvider>();
    final catalog = context.watch<CatalogProvider>();

    final catalogGagal = catalog.errorMessage != null && catalog.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: RefreshIndicator(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.welcome,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: AppSizes.spacingXs),
                  Text(
                    l10n.subWelcome,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSizes.spacingL),

                  _buildLanjutkanSection(context, collection, l10n),
                  const SizedBox(height: AppSizes.spacingL),
                  _buildStatistikSection(context, collection, l10n),
                  const SizedBox(height: AppSizes.spacingL),

                  if (catalogGagal)
                    ErrorView(
                      message: catalog.errorMessage!,
                      onRetry: () =>
                          context.read<CatalogProvider>().refresh(),
                    )
                  else ...[
                    _buildPopulerSection(
                      context,
                      l10n,
                      title: l10n.popularAnime,
                      items: catalog.topAnime,
                      isLoading: catalog.isLoading && catalog.items.isEmpty,
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    _buildPopulerSection(
                      context,
                      l10n,
                      title: l10n.popularManga,
                      items: catalog.topManga,
                      isLoading: catalog.isLoading && catalog.items.isEmpty,
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistikSection(
      BuildContext context, CollectionProvider collection, AppLocalizations l10n) {
    if (collection.isLoading && collection.allEntries.isEmpty) {
      return const Row(
        children: [
          Expanded(child: ShimmerLoading(height: 100)),
          SizedBox(width: AppSizes.spacingM),
          Expanded(child: ShimmerLoading(height: 100)),
          SizedBox(width: AppSizes.spacingM),
          Expanded(child: ShimmerLoading(height: 100)),
        ],
      );
    }

    final total = collection.allEntries.length;
    final sedang = collection.allEntries
        .where((e) => e.status == StatusKoleksi.sedang)
        .length;
    final selesai = collection.allEntries
        .where((e) => e.status == StatusKoleksi.selesai)
        .length;

    final cards = [
      _statCard(context, l10n.statTotal, total.toString(),
          Icons.collections_bookmark, AppColors.infoBlue),
      _statCard(context, l10n.statReading, sedang.toString(),
          Icons.play_circle_outline, AppColors.primaryGreen),
      _statCard(context, l10n.statCompleted, selesai.toString(),
          Icons.check_circle_outline, AppColors.goldPrimary),
    ];

    final textScale = MediaQuery.textScalerOf(context).scale(1);

    if (textScale > 1.3) {
      return Column(
        children: [
          for (final card in cards)
            Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                child: card),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSizes.spacingM),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSizes.spacingS),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanjutkanSection(
      BuildContext context, CollectionProvider collection, AppLocalizations l10n) {
    final lanjutkan = collection.allEntries
        .where((e) => e.status == StatusKoleksi.sedang)
        .take(3)
        .toList();

    if (lanjutkan.isEmpty) {
      return Card(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            children: [
              const Icon(Icons.play_circle_outline,
                  size: 48, color: Colors.grey),
              const SizedBox(height: AppSizes.spacingM),
              Text(l10n.noTrackedYet,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                l10n.searchFirst,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingM),
              ElevatedButton(
                onPressed: widget.onLihatKatalog,
                child: Text(l10n.searchNow),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.continueWatching,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.spacingS),
        ...lanjutkan.map((terbaru) {
          final progress = (terbaru.total != null && terbaru.total! > 0)
              ? (terbaru.progres / terbaru.total!).clamp(0.0, 1.0)
              : 0.0;

          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CoverImage(
                  url: terbaru.coverUrl,
                  width: 50,
                  height: 70,
                ),
              ),
              title: Text(terbaru.judul,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${terbaru.progres} / ${terbaru.total ?? "?"} ${terbaru.jenis.satuanProgres(l10n)}'), // <-- Perbaikan
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    color: AppColors.primaryGreen,
                    minHeight: 4,
                  ),
                ],
              ),
              trailing: IconButton.filledTonal(
                icon: const Icon(Icons.add),
                tooltip: 'Tambah progres',
                onPressed:
                    (terbaru.total != null && terbaru.progres >= terbaru.total!)
                        ? null
                        : () async {
                            final provider =
                                context.read<CollectionProvider>();
                            await provider.incrementProgress(terbaru);

                            if (!context.mounted) return;
                            
                            if (provider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.errorMessage!)),
                              );
                              return;
                            }

                            final updated = provider.allEntries.firstWhere(
                              (e) => e.id == terbaru.id,
                              orElse: () => terbaru,
                            );
                            if (updated.status == StatusKoleksi.selesai) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Selamat! Kamu telah menamatkan judul ini.'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Progres +1 berhasil.'),
                                ),
                              );
                            }
                          },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CollectionDetailPage(entri: terbaru),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPopulerSection(
    BuildContext context,
    AppLocalizations l10n, {
    required String title,
    required List<ItemKatalog> items,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: widget.onLihatKatalog,
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (isLoading)
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(right: AppSizes.spacingM),
                child: ShimmerLoading(width: 140),
              ),
            ),
          )
        else if (items.isEmpty)
          const EmptyView(
            title: 'Belum Ada Data',
            subtitle: 'Data populer tidak dapat dimuat.',
            icon: Icons.inbox_outlined,
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth / 2.4)
                  .clamp(130.0, 180.0)
                  .toDouble();
              final textScale =
                  MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
              final listHeight =
                  (cardWidth * 1.5) + AppSizes.spacingS + (40 * textScale);

              return SizedBox(
                height: listHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSizes.spacingM),
                      child: MediaCard(
                        item: item,
                        width: cardWidth,
                        heroTag: 'home_${item.malId}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CatalogDetailPage(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}