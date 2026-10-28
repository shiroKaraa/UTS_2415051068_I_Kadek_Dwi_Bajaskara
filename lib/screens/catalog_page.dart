import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/media_type_enum.dart';
import '../providers/catalog_provider.dart';
import '../widgets/media_card.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/skeleton/skeleton_grid_card.dart';
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
  Timer? _scrollThrottle;
  CatalogProvider? _catalogProvider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_scrollThrottle?.isActive ?? false) return;
        
        _scrollThrottle = Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.read<CatalogProvider>().loadMore();
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final catalog = Provider.of<CatalogProvider>(context, listen: false);
    
    if (_catalogProvider != catalog) {
      _catalogProvider?.removeListener(_syncSearchController);
      _catalogProvider = catalog;
      _catalogProvider?.addListener(_syncSearchController);
    }
  }

  void _syncSearchController() {
    if (_catalogProvider == null) return;
    if (_catalogProvider!.query.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _catalogProvider?.removeListener(_syncSearchController);
    _scrollThrottle?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    final catalog = context.read<CatalogProvider>();
    String? tempGenre = catalog.filterGenre;
    int? tempTahun = catalog.filterTahun;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.filterCatalog, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: tempGenre,
                    decoration: InputDecoration(labelText: 'Genre', border: const OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.allGenres)),
                      const DropdownMenuItem(value: 'Action', child: Text('Action')),
                      const DropdownMenuItem(value: 'Romance', child: Text('Romance')),
                      const DropdownMenuItem(value: 'Comedy', child: Text('Comedy')),
                      const DropdownMenuItem(value: 'Fantasy', child: Text('Fantasy')),
                      const DropdownMenuItem(value: 'Sci-Fi', child: Text('Sci-Fi')),
                    ],
                    onChanged: (val) => setState(() => tempGenre = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: tempTahun,
                    decoration: InputDecoration(labelText: l10n.allYears, border: const OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.allYears)),
                      ...List.generate(10, (i) => DateTime.now().year - i).map((thn) {
                        return DropdownMenuItem(value: thn, child: Text(thn.toString()));
                      }),
                    ],
                    onChanged: (val) => setState(() => tempTahun = val),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            catalog.clearFilters();
                            Navigator.pop(sheetCtx);
                          },
                          child: Text(l10n.reset),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            catalog.setFilters(genre: tempGenre, tahun: tempTahun);
                            Navigator.pop(sheetCtx);
                          },
                          child: Text(l10n.apply),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context, l10n),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  context.read<CatalogProvider>().setQuery(value);
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, value, _) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ...JenisMedia.values.map((jenis) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(jenis.label(l10n)),
                      selected: catalog.selectedJenis == jenis,
                      onSelected: (selected) {
                        if (selected) catalog.setJenis(jenis);
                      },
                    ),
                  );
                }),
                if (catalog.filterGenre != null || catalog.filterTahun != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Chip(
                      avatar: const Icon(Icons.filter_alt, size: 16),
                      label: Text(l10n.activeFilter),
                      onDeleted: () {
                        _searchController.clear();
                        catalog.clearFilters();
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          if (!catalog.isLoading && catalog.errorMessage == null && catalog.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.trackedTitles(catalog.items.length),
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          Expanded(
            child: _buildContent(context, catalog, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CatalogProvider catalog, AppLocalizations l10n) {
    if (catalog.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 0.55,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 6,
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
          catalog.clearFilters();
        },
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      cacheExtent: 500.0,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}