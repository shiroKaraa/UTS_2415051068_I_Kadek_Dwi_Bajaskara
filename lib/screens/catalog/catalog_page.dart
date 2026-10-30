import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/media_type_enum.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/media_card.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/skeleton/skeleton_grid_card.dart';
import '../../widgets/skeleton/skeleton_list_card.dart';
import 'catalog_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

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
      final catalog = context.read<CatalogProvider>();
      if (catalog.items.isEmpty) {
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
                Future<void> showMultiSelectDialog({
                  required String title,
                  required List<String> allItems,
                  required List<String> selectedItems,
                  required Function(List<String>) onSave,
                }) async {
                  final result = await showDialog<List<String>>(
                    context: context,
                    builder: (dialogCtx) {
                      final tempSelected = List<String>.from(selectedItems);
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text(title),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: allItems.length,
                                itemBuilder: (context, index) {
                                  final item = allItems[index];
                                  final isSelected = tempSelected.contains(item);
                                  return CheckboxListTile(
                                    title: Text(item),
                                    value: isSelected,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          tempSelected.add(item);
                                        } else {
                                          tempSelected.remove(item);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx, tempSelected),
                                child: Text(l10n.apply),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                  if (result != null) {
                    onSave(result);
                  }
                }

                return DraggableScrollableSheet(
                  initialChildSize: 0.85,
                  minChildSize: 0.6,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (_, scrollController) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSizes.spacingM, AppSizes.spacingM, AppSizes.spacingM, 0),
                          child: Text(l10n.filterCatalog,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(AppSizes.spacingM),
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(l10n.filterGenre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(tempGenres.isEmpty ? l10n.allGenres : tempGenres.join(', ')),
                                trailing: catalog.isLoadingGenres
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.arrow_drop_down),
                                onTap: () {
                                  if (catalog.isLoadingGenres) return;
                                  if (catalog.availableGenres.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Gagal memuat data genre. Periksa koneksi internet.')),
                                    );
                                    return;
                                  }
                                  showMultiSelectDialog(
                                    title: l10n.filterGenre,
                                    allItems: catalog.availableGenres,
                                    selectedItems: tempGenres,
                                    onSave: (selected) => setState(() => tempGenres = selected),
                                  );
                                },
                              ),
                              const Divider(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Tag', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(tempTags.isEmpty ? 'Semua Tag' : tempTags.join(', ')),
                                trailing: catalog.isLoadingTags
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.arrow_drop_down),
                                onTap: () {
                                  if (catalog.isLoadingTags) return;
                                  if (catalog.availableTags.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Gagal memuat data tag. Periksa koneksi internet.')),
                                    );
                                    return;
                                  }
                                  showMultiSelectDialog(
                                    title: 'Tag',
                                    allItems: catalog.availableTags,
                                    selectedItems: tempTags,
                                    onSave: (selected) => setState(() => tempTags = selected),
                                  );
                                },
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                                child: DropdownButtonFormField<String>(
                                  initialValue: tempStatus,
                                  decoration: InputDecoration(labelText: l10n.filterStatus, border: const OutlineInputBorder(), isDense: true),
                                  items: [
                                    DropdownMenuItem(value: null, child: Text(l10n.all)),
                                    DropdownMenuItem(value: 'RELEASING', child: Text(l10n.statusAiring)),
                                    DropdownMenuItem(value: 'FINISHED', child: Text(l10n.statusFinished)),
                                    DropdownMenuItem(value: 'NOT_YET_RELEASED', child: Text(l10n.statusUpcoming)),
                                  ],
                                  onChanged: (val) => setState(() => tempStatus = val),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                                child: DropdownButtonFormField<int>(
                                  initialValue: tempTahun,
                                  decoration: InputDecoration(labelText: l10n.filterYear, border: const OutlineInputBorder(), isDense: true),
                                  items: [
                                    DropdownMenuItem(value: null, child: Text(l10n.all)),
                                    ...List.generate(30, (i) => DateTime.now().year - i).map((thn) {
                                      return DropdownMenuItem(value: thn, child: Text(thn.toString()));
                                    }),
                                  ],
                                  onChanged: (val) => setState(() => tempTahun = val),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                                child: DropdownButtonFormField<int>(
                                  initialValue: tempSkorMin,
                                  decoration: InputDecoration(labelText: l10n.filterScore, border: const OutlineInputBorder(), isDense: true),
                                  items: [
                                    DropdownMenuItem(value: null, child: Text(l10n.all)),
                                    DropdownMenuItem(value: 5, child: Text('≥ 5')),
                                    DropdownMenuItem(value: 6, child: Text('≥ 6')),
                                    DropdownMenuItem(value: 7, child: Text('≥ 7')),
                                    DropdownMenuItem(value: 8, child: Text('≥ 8')),
                                    DropdownMenuItem(value: 9, child: Text('≥ 9')),
                                  ],
                                  onChanged: (val) => setState(() => tempSkorMin = val),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                                child: DropdownButtonFormField<UrutanKatalog>(
                                  initialValue: tempUrutan,
                                  decoration: InputDecoration(labelText: l10n.sortBy, border: const OutlineInputBorder(), isDense: true),
                                  items: [
                                    DropdownMenuItem(value: UrutanKatalog.populer, child: Text(l10n.sortPopular)),
                                    if (catalog.query.isNotEmpty)
                                      DropdownMenuItem(value: UrutanKatalog.relevan, child: const Text('Relevan')),
                                    DropdownMenuItem(value: UrutanKatalog.skor, child: Text(l10n.sortScore)),
                                    DropdownMenuItem(value: UrutanKatalog.terbaru, child: Text(l10n.sortNewest)),
                                    DropdownMenuItem(value: UrutanKatalog.judul, child: Text(l10n.sortTitle)),
                                  ],
                                  onChanged: (val) { if (val != null) setState(() => tempUrutan = val); },
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
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                                      side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                    ),
                                    child: Text(l10n.apply,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCatalog),
        actions: [
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
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
            child: Row(
              children: [
                ...JenisMedia.values.where((jenis) => jenis != JenisMedia.lainnya).map((jenis) {
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

          if (!catalog.isLoading &&
              catalog.errorMessage == null &&
              catalog.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.showingResults(
                      catalog.items.length, catalog.totalResults),
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<CatalogProvider>().refresh(),
              child: _buildContent(context, catalog, l10n),
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
      BuildContext context, CatalogProvider catalog, AppLocalizations l10n) {
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
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 180 * 1.5 + (56 * MediaQuery.textScalerOf(context).scale(1.0)),
        ),
        itemCount: 12,
        itemBuilder: (context, index) => const SkeletonGridCard(),
      );
    }

    if (catalog.errorMessage != null) {
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
                child:
                    CoverImage(url: item.coverUrl, width: 50, height: 70),
              ),
              title: Text(item.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 180 * 1.5 + (56 * MediaQuery.textScalerOf(context).scale(1.0)),
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