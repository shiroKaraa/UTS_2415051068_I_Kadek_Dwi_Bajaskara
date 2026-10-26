import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_type_enum.dart';
import '../providers/catalog_provider.dart';
import '../widgets/media_card.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import 'catalog_detail_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => catalog.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: catalog.selectedJenis == null,
                  onSelected: (selected) {
                    if (selected) catalog.setFilter(null);
                  },
                ),
                const SizedBox(width: 8),
                ...JenisMedia.values.map((jenis) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(jenis.label),
                      selected: catalog.selectedJenis == jenis,
                      onSelected: (selected) {
                        if (selected) catalog.setFilter(jenis);
                      },
                    ),
                  );
                }),
              ],
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
      return const Center(child: CircularProgressIndicator());
    }

    if (catalog.errorMessage != null) {
      return ErrorView(
        message: catalog.errorMessage!,
        onRetry: () => catalog.refresh(),
      );
    }

    final filteredItems = catalog.selectedJenis == null
        ? catalog.items
        : catalog.items.where((item) => item.jenis == catalog.selectedJenis).toList();

    if (filteredItems.isEmpty) {
      return const EmptyView(
        title: 'Tidak Ada Hasil',
        subtitle: 'Coba ubah filter jenis media.',
        icon: Icons.search_off,
      );
    }

    return ResponsiveGrid(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
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
    );
  }
}