import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/collection_entry.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/collection_card.dart';
import 'collection_detail_page.dart';
import 'edit_entry_page.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi'),
        actions: [
          PopupMenuButton<UrutanKoleksi>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            onSelected: (value) => collection.setUrutan(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: UrutanKoleksi.terbaru,
                child: Row(
                  children: [
                    if (collection.urutan == UrutanKoleksi.terbaru)
                      const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Terbaru'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: UrutanKoleksi.judul,
                child: Row(
                  children: [
                    if (collection.urutan == UrutanKoleksi.judul)
                      const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Judul A-Z'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => collection.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (collection.isOffline)
            Container(
              width: double.infinity,
              color: AppColors.goldPrimary.withValues(alpha: 0.2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: AppColors.goldPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Mode Offline: Menampilkan data tersimpan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: collection.filterStatus == null,
                    onSelected: (selected) {
                      if (selected) collection.setFilterStatus(null);
                    },
                  ),
                ),
                ...StatusKoleksi.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(status.netralLabel),
                      selected: collection.filterStatus == status,
                      onSelected: (selected) {
                        if (selected) collection.setFilterStatus(status);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => collection.refresh(),
              child: _buildContent(context, collection),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CollectionProvider collection) {
    if (collection.isLoading && collection.allEntries.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 0.6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerLoading(),
      );
    }

    if (collection.errorMessage != null && collection.allEntries.isEmpty) {
      return ErrorView(
        message: collection.errorMessage!,
        onRetry: () => collection.refresh(),
      );
    }

    if (collection.entries.isEmpty) {
      return const EmptyView(
        title: 'Koleksi Kosong',
        subtitle: 'Cari judul di Katalog dan tambahkan yang pertama.',
        icon: Icons.collections_bookmark_outlined,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.6,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: collection.entries.length,
      itemBuilder: (context, index) {
        final entri = collection.entries[index];
        return CollectionCard(
          entri: entri,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailPage(entri: entri),
              ),
            );
          },
          onLongPress: () {
            _showQuickMenu(context, entri);
          },
        );
      },
    );
  }

  void _showQuickMenu(BuildContext context, EntriKoleksi entri) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final collection = context.read<CollectionProvider>();

    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(sheetCtx);
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => EditEntryPage(entri: entri),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Hapus',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('Hapus Koleksi?'),
                    content: Text(
                      'Apakah kamu yakin ingin menghapus "${entri.judul}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                final berhasil = await collection.deleteEntry(entri);
                
                if (berhasil) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const Text('Koleksi berhasil dihapus.'),
                      action: SnackBarAction(
                        label: 'Urungkan',
                        onPressed: () {
                          // Logika Undo: Panggil createEntry kembali
                          collection.createEntry(entri);
                        },
                      ),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text(collection.errorMessage ?? 'Gagal menghapus.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}