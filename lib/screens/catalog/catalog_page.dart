import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../core/title_actions.dart';
import '../../models/card_size_enum.dart';
import '../../models/media_type_enum.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/media_card.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/display_mode_sheet.dart';
import '../../widgets/skeleton/skeleton_grid_card.dart';
import '../../widgets/skeleton/skeleton_list_card.dart';
import 'catalog_detail_page.dart';

class CatalogPage extends StatefulWidget {
  final JenisMedia? initialJenis;
  final List<String>? initialGenres;
  final int? initialTahun;
  final String? initialStatus;
  final int? initialSkorMin;
  final String? initialQuery;

  const CatalogPage({
    super.key,
    this.initialJenis,
    this.initialGenres,
    this.initialTahun,
    this.initialStatus,
    this.initialSkorMin,
    this.initialQuery,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final catalog = context.read<CatalogProvider>();

      final hasInitial = widget.initialJenis != null ||
          (widget.initialGenres != null && widget.initialGenres!.isNotEmpty) ||
          widget.initialTahun != null ||
          widget.initialStatus != null ||
          widget.initialSkorMin != null ||
          (widget.initialQuery != null &&
              widget.initialQuery!.trim().isNotEmpty);

      if (hasInitial) {
        if (widget.initialQuery != null &&
            widget.initialQuery!.trim().isNotEmpty) {
          final q = widget.initialQuery!.trim();
          _searchController.text = q;
          catalog.setQuery(q);
        }
        if (widget.initialJenis != null) {
          catalog.setJenis(widget.initialJenis!);
        }
        catalog.setFilters(
          genres: widget.initialGenres ?? const [],
          tahun: widget.initialTahun,
          status: widget.initialStatus,
          skorMin: widget.initialSkorMin,
        );
      } else if (catalog.items.isEmpty) {
        catalog.fetchCatalog();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
        context.read<CatalogProvider>().loadMore();
      }

      final shouldShow = _scrollController.position.pixels > 500;
      if (shouldShow != _showBackToTop) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _showBackToTop = shouldShow);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _searchByTitle(String title) {
    _debounceTimer?.cancel();
    _searchController.text = title;
    context.read<CatalogProvider>().setQuery(title);
    _scrollToTop();
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    final catalog = context.read<CatalogProvider>();
    catalog.ensureGenres();
    catalog.ensureTags();

    List<String> tempGenres = List.from(catalog.filterGenres);
    List<String> tempTags = List.from(catalog.filterTags);
    int? tempTahun = catalog.filterTahun;
    String? tempStatus = catalog.filterStatus;
    UrutanKatalog tempUrutan = catalog.urutan;
    int? tempSkorMin = catalog.filterSkorMin;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return ListenableBuilder(
          listenable: catalog,
          builder: (context, _) {
            return StatefulBuilder(
              builder: (context, setState) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.85,
                  minChildSize: 0.6,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (_, scrollController) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.spacingM,
                              AppSizes.spacingM, AppSizes.spacingM, 0),
                          child: Text(l10n.filterCatalog,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(AppSizes.spacingM),
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(l10n.filterGenre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(tempGenres.isEmpty
                                    ? l10n.allGenres
                                    : tempGenres.join(', ')),
                                trailing: catalog.isLoadingGenres
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.arrow_drop_down),
                                onTap: () {
                                  if (catalog.isLoadingGenres) return;
                                  if (catalog.availableGenres.isEmpty) {
                                    catalog.ensureGenres();
                                    return;
                                  }
                                  showDialog<List<String>>(
                                    context: context,
                                    builder: (_) => MultiSelectDialog(
                                      title: l10n.filterGenre,
                                      items: catalog.availableGenres,
                                      selected: tempGenres,
                                    ),
                                  ).then((selected) {
                                    if (selected != null) {
                                      setState(() => tempGenres = selected);
                                    }
                                  });
                                },
                              ),
                              const Divider(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Tag',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(tempTags.isEmpty
                                    ? 'Semua Tag'
                                    : tempTags.join(', ')),
                                trailing: catalog.isLoadingTags
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Icon(Icons.arrow_drop_down),
                                onTap: () {
                                  if (catalog.isLoadingTags) return;
                                  if (catalog.availableTags.isEmpty) {
                                    catalog.ensureTags();
                                    return;
                                  }
                                  showDialog<List<String>>(
                                    context: context,
                                    builder: (_) => MultiSelectDialog(
                                      title: 'Tag',
                                      items: catalog.availableTags,
                                      selected: tempTags,
                                    ),
                                  ).then((selected) {
                                    if (selected != null) {
                                      setState(() => tempTags = selected);
                                    }
                                  });
                                },
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, bottom: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Genre dan Tag digabung (AND). Semakin banyak dipilih, hasil semakin sedikit.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.spacingS),
                                child: DropdownButtonFormField<int>(
                                  initialValue: tempTahun,
                                  decoration: InputDecoration(
                                      labelText: l10n.filterYear,
                                      border: const OutlineInputBorder(),
                                      isDense: true),
                                  items: [
                                    DropdownMenuItem(
                                        value: null, child: Text(l10n.all)),
                                    ...List.generate(
                                            30, (i) => DateTime.now().year - i)
                                        .map((thn) {
                                      return DropdownMenuItem(
                                          value: thn,
                                          child: Text(thn.toString()));
                                    }),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => tempTahun = val),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.spacingS),
                                child: DropdownButtonFormField<int>(
                                  initialValue: tempSkorMin,
                                  decoration: InputDecoration(
                                      labelText: l10n.filterScore,
                                      border: const OutlineInputBorder(),
                                      isDense: true),
                                  items: [
                                    DropdownMenuItem(
                                        value: null, child: Text(l10n.all)),
                                    DropdownMenuItem(
                                        value: 5, child: Text('≥ 5')),
                                    DropdownMenuItem(
                                        value: 6, child: Text('≥ 6')),
                                    DropdownMenuItem(
                                        value: 7, child: Text('≥ 7')),
                                    DropdownMenuItem(
                                        value: 8, child: Text('≥ 8')),
                                    DropdownMenuItem(
                                        value: 9, child: Text('≥ 9')),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => tempSkorMin = val),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.spacingS),
                                child: DropdownButtonFormField<String>(
                                  initialValue: tempStatus,
                                  decoration: InputDecoration(
                                    labelText: l10n.filterStatus,
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: null, child: Text(l10n.all)),
                                    DropdownMenuItem(
                                        value: 'RELEASING',
                                        child: Text(l10n.statusAiring)),
                                    DropdownMenuItem(
                                        value: 'FINISHED',
                                        child: Text(l10n.statusFinished)),
                                    DropdownMenuItem(
                                        value: 'NOT_YET_RELEASED',
                                        child: Text(l10n.statusUpcoming)),
                                    DropdownMenuItem(
                                        value: 'CANCELLED',
                                        child: Text(l10n.statusDropped)),
                                    DropdownMenuItem(
                                        value: 'HIATUS',
                                        child: Text(l10n.statusPaused)),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => tempStatus = val),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.spacingS),
                                child:
                                    DropdownButtonFormField<UrutanKatalog>(
                                  initialValue: tempUrutan,
                                  decoration: InputDecoration(
                                      labelText: l10n.sortBy,
                                      border: const OutlineInputBorder(),
                                      isDense: true),
                                  items: [
                                    DropdownMenuItem(
                                        value: UrutanKatalog.populer,
                                        child: Text(l10n.sortPopular)),
                                    if (catalog.query.isNotEmpty)
                                      DropdownMenuItem(
                                          value: UrutanKatalog.relevan,
                                          child: const Text('Relevan')),
                                    DropdownMenuItem(
                                        value: UrutanKatalog.skor,
                                        child: Text(l10n.sortScore)),
                                    DropdownMenuItem(
                                        value: UrutanKatalog.terbaru,
                                        child: Text(l10n.sortNewest)),
                                    DropdownMenuItem(
                                        value: UrutanKatalog.judul,
                                        child: Text(l10n.sortTitle)),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => tempUrutan = val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: AppSizes.spacingXl),
                            ],
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.spacingM),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      catalog.clearFilters();
                                      Navigator.pop(sheetCtx);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                    child: Text(l10n.reset),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.spacingM),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      catalog.setFilters(
                                        genres: tempGenres,
                                        tags: tempTags,
                                        tahun: tempTahun,
                                        status: tempStatus,
                                        urutan: tempUrutan,
                                        skorMin: tempSkorMin,
                                      );
                                      Navigator.pop(sheetCtx);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      backgroundColor: AppColors.primaryGreen
                                          .withValues(alpha: 0.15),
                                      side: const BorderSide(
                                          color: AppColors.primaryGreen,
                                          width: 1.5),
                                    ),
                                    child: Text(l10n.apply,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final catalog = context.watch<CatalogProvider>();
    context.watch<SettingsProvider>();

    final cardSize =
        context.select<SettingsProvider, CardSize>((s) => s.cardSize);
    final itemsPerRow =
        context.select<SettingsProvider, int>((s) => s.itemsPerRow);
    final screenWidth = MediaQuery.sizeOf(context).width;
    const padding = AppSizes.spacingM * 2;
    const spacing = 16.0;
    final columnWidth =
        (screenWidth - padding - (spacing * (itemsPerRow - 1))) / itemsPerRow;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final posterHeight = columnWidth / (2 / 3);
    final mainAxisExtent = posterHeight + (cardSize.textExtra * textScale);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCatalog),
        actions: [
        IconButton(
          icon: const Icon(Icons.shuffle),
          tooltip: l10n.randomPick,
          onPressed: () {
            final item = catalog.getRandomItem();
            if (item == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.noResults)),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CatalogDetailPage(item: item),
              ),
            );
          },
        ),
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.filter_list),
              if (catalog.hasActiveFilters)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          tooltip: l10n.filterTooltip,
          onPressed: () => _showFilterSheet(context, l10n),
        ),
        IconButton(
          icon: Icon(catalog.isListView ? Icons.grid_view : Icons.view_list),
          tooltip: catalog.isListView ? l10n.gridView : l10n.listView,
          onPressed: () => catalog.toggleView(),
        ),
        IconButton(
          icon: const Icon(Icons.view_quilt_outlined),
          tooltip: l10n.displayMode,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const DisplayModeSheet(),
            );
          },
        ),
      ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _debounceTimer?.cancel();
                context.read<CatalogProvider>().setQuery(value.trim());
              },
              onChanged: (value) {
                if (_debounceTimer?.isActive ?? false) {
                  _debounceTimer!.cancel();
                }
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  context.read<CatalogProvider>().setQuery(value.trim());
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _debounceTimer?.cancel();
                              _searchController.clear();
                              context.read<CatalogProvider>().setQuery('');
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
            child: Row(
              children: [
                ...JenisMedia.values
                    .where((jenis) => jenis != JenisMedia.lainnya)
                    .map((jenis) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(jenis.label(l10n)),
                      selected: catalog.selectedJenis == jenis,
                      onSelected: (selected) {
                        if (selected) {
                          catalog.setJenis(jenis);
                          _scrollToTop();
                        }
                      },
                    ),
                  );
                }),
                if (catalog.hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.filter_alt, size: 16),
                    label: Text(l10n.clearAll),
                    onPressed: () {
                      _searchController.clear();
                      catalog.clearAll();
                      _scrollToTop();
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          if (!catalog.isLoading && catalog.items.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      (catalog.hasNextPage &&
                              catalog.items.length < catalog.totalResults)
                          ? l10n.showingResultsPartial(
                              catalog.items.length, catalog.totalResults)
                          : l10n.showingResults(
                              catalog.items.length,
                              catalog.totalResults > 0
                                  ? catalog.totalResults
                                  : catalog.items.length),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (catalog.errorMessage != null)
                    TextButton.icon(
                      onPressed: () => catalog.refresh(),
                      icon: const Icon(Icons.refresh,
                          size: 14, color: Colors.redAccent),
                      label: const Text(
                        'Coba Lagi',
                        style: TextStyle(fontSize: 11, color: Colors.redAccent),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<CatalogProvider>().refresh(),
              child: _buildContent(
                context,
                catalog,
                l10n,
                itemsPerRow,
                mainAxisExtent,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    CatalogProvider catalog,
    AppLocalizations l10n,
    int itemsPerRow,
    double mainAxisExtent,
  ) {
    if (catalog.isLoading) {
      if (catalog.isListView) {
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          itemCount: 6,
          itemBuilder: (context, index) => const SkeletonListCard(),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemsPerRow,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: mainAxisExtent,
        ),
        itemCount: 12,
        itemBuilder: (context, index) => const SkeletonGridCard(),
      );
    }
    if (catalog.errorMessage != null && catalog.items.isEmpty) {
      return ErrorView(
        message: catalog.errorMessage!,
        onRetry: () => catalog.refresh(),
      );
    }
    if (catalog.items.isEmpty) {
      return EmptyView(
        title: l10n.noResults,
        subtitle: l10n.noResultsDesc,
        icon: Icons.search_off,
        actionLabel: l10n.resetFilter,
        onAction: () {
          _searchController.clear();
          catalog.clearAll();
        },
      );
    }
    if (catalog.isListView) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSizes.spacingM),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: catalog.items.length + 1,
        itemBuilder: (context, index) {
          if (index == catalog.items.length) {
            if (catalog.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(AppSizes.spacingM),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (catalog.loadMoreError != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => catalog.retryLoadMore(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.loadMoreFailed),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          final item = catalog.items[index];
          return Card(
            key: ValueKey(item.anilistId),
            margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CoverImage(url: item.coverUrl, width: 50, height: 70),
              ),
              title: GestureDetector(
                onLongPress: () => showTitleActions(
                  context,
                  title: item.displayTitle,
                  onSearch: () => _searchByTitle(item.displayTitle),
                ),
                child: Text(
                  item.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text(
                '${item.total ?? "?"} ${item.jenis.satuanProgres(l10n)}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              trailing: item.skor != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.goldPrimary),
                        const SizedBox(width: 4),
                        Text(item.skor!.toStringAsFixed(1)),
                      ],
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CatalogDetailPage(item: item),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: itemsPerRow,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: mainAxisExtent,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = catalog.items[index];
                return MediaCard(
                  item: item,
                  heroTag: 'catalog_${item.anilistId}',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CatalogDetailPage(item: item),
                      ),
                    );
                  },
                  onSearch: () => _searchByTitle(item.displayTitle),
                );
              },
              childCount: catalog.items.length,
              addAutomaticKeepAlives: false,
            ),
          ),
        ),
        if (catalog.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.spacingM),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (catalog.loadMoreError != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => catalog.retryLoadMore(),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.loadMoreFailed),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selected;

  const MultiSelectDialog({
    super.key,
    required this.title,
    required this.items,
    required this.selected,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late final Set<String> _sel = widget.selected.toSet();
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = widget.items
        .where((e) => e.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                isDense: true,
                hintText: 'Cari...',
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final it = filtered[i];
                  return CheckboxListTile(
                    dense: true,
                    title: Text(it),
                    value: _sel.contains(it),
                    onChanged: (v) => setState(
                        () => v == true ? _sel.add(it) : _sel.remove(it)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel)),
        TextButton(
            onPressed: () => Navigator.pop(context, _sel.toList()),
            child: Text(l10n.apply)),
      ],
    );
  }
}