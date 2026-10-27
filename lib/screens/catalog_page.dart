import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<CatalogProvider>().loadMore();
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

  void _showFilterSheet(BuildContext context) {
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
                  const Text('Filter Katalog', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: tempGenre,
                    decoration: const InputDecoration(labelText: 'Genre', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Semua Genre')),
                      DropdownMenuItem(value: 'Action', child: Text('Action')),
                      DropdownMenuItem(value: 'Romance', child: Text('Romance')),
                      DropdownMenuItem(value: 'Comedy', child: Text('Comedy')),
                      DropdownMenuItem(value: 'Fantasy', child: Text('Fantasy')),
                      DropdownMenuItem(value: 'Sci-Fi', child: Text('Sci-Fi')),
                    ],
                    onChanged: (val) => setState(() => tempGenre = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: tempTahun,
                    decoration: const InputDecoration(labelText: 'Tahun Rilis', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Tahun')),
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
                            catalog.clearFilters();
                            Navigator.pop(sheetCtx);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            catalog.setFilters(genre: tempGenre, tahun: tempTahun);
                            Navigator.pop(sheetCtx);
                          },
                          child: const Text('Terapkan'),
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
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context),
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
                setState(() {});
                if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  context.read<CatalogProvider>().setQuery(value);
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari judul...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _debounceTimer?.cancel();
                        _searchController.clear();
                        context.read<CatalogProvider>().setQuery('');
                        setState(() {});
                      },
                    )
                    : null,
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
                      label: Text(jenis.label),
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
                      label: const Text('Filter Aktif'),
                      onDeleted: () => catalog.clearFilters(),
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
                  'Menampilkan ${catalog.items.length} hasil',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          Expanded(
            child: _buildContent(context, catalog),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CatalogProvider catalog) {
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
        title: 'Tidak Ditemukan',
        subtitle: 'Coba kata kunci lain, ubah jenis media, atau reset filter.',
        icon: Icons.search_off,
        actionLabel: 'Reset Filter',
        onAction: () => catalog.clearFilters(),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
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