import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_sizes.dart';
import '../../models/media_type_enum.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/media_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/skeleton/skeleton_grid_card.dart';
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

      if (_scrollController.position.pixels > 500 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.position.pixels <= 500 && _showBackToTop) {
        setState(() => _showBackToTop = false);
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
    
    List<String> tempGenres = List.from(catalog.filterGenres);
    int? tempTahun = catalog.filterTahun;
    String? tempStatus = catalog.filterStatus;
    UrutanKatalog tempUrutan = catalog.urutan;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.spacingM),
                  children: [
                    Text(l10n.filterCatalog, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.spacingM),
                    
                    Text(l10n.filterGenre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.spacingS),
                    Wrap(
                      spacing: AppSizes.spacingS,
                      runSpacing: AppSizes.spacingS,
                      children: catalog.availableGenres.map((genre) {
                        final isSelected = tempGenres.contains(genre);
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                tempGenres.add(genre);
                              } else {
                                tempGenres.remove(genre);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSizes.spacingL),

                    Text(l10n.filterStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.spacingS),
                    DropdownButtonFormField<String>(
                      initialValue: tempStatus,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.all)),
                        DropdownMenuItem(value: 'RELEASING', child: Text(l10n.statusAiring)),
                        DropdownMenuItem(value: 'FINISHED', child: Text(l10n.statusFinished)),
                        DropdownMenuItem(value: 'NOT_YET_RELEASED', child: Text(l10n.statusUpcoming)),
                      ],
                      onChanged: (val) => setState(() => tempStatus = val),
                    ),
                    const SizedBox(height: AppSizes.spacingL),

                    Text(l10n.filterYear, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.spacingS),
                    DropdownButtonFormField<int>(
                      initialValue: tempTahun,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.all)),
                        ...List.generate(10, (i) => DateTime.now().year - i).map((thn) {
                          return DropdownMenuItem(value: thn, child: Text(thn.toString()));
                        }),
                      ],
                      onChanged: (val) => setState(() => tempTahun = val),
                    ),
                    const SizedBox(height: AppSizes.spacingL),

                    Text(l10n.sortBy, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.spacingS),
                    DropdownButtonFormField<UrutanKatalog>(
                      initialValue: tempUrutan,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                      items: [
                        DropdownMenuItem(value: UrutanKatalog.populer, child: Text(l10n.sortPopular)),
                        DropdownMenuItem(value: UrutanKatalog.skor, child: Text(l10n.sortScore)),
                        DropdownMenuItem(value: UrutanKatalog.terbaru, child: Text(l10n.sortNewest)),
                        DropdownMenuItem(value: UrutanKatalog.judul, child: Text(l10n.sortTitle)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => tempUrutan = val);
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingXl),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              catalog.clearFilters();
                              Navigator.pop(sheetCtx);
                            },
                            child: Text(l10n.reset),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              catalog.setFilters(
                                genres: tempGenres,
                                tahun: tempTahun,
                                status: tempStatus,
                                urutan: tempUrutan,
                              );
                              Navigator.pop(sheetCtx);
                            },
                            child: Text(l10n.apply),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingXl),
                  ],
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
    if (catalog.isLoading && _showBackToTop) {
      _showBackToTop = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCatalog),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context, l10n),
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
                if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
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
                ...JenisMedia.values.map((jenis) {
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
          
          if (!catalog.isLoading && catalog.errorMessage == null && catalog.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.showingResults(catalog.items.length, catalog.totalResults),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
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

  Widget _buildContent(BuildContext context, CatalogProvider catalog, AppLocalizations l10n) {
    if (catalog.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 0.55,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
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

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              childAspectRatio: 0.55,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = catalog.items[index];
                return MediaCard(
                  item: item,
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