import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/collection_entry.dart';
import '../models/media_type_enum.dart'; 
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/shimmer_loading.dart';
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
                    if (collection.urutan == UrutanKoleksi.terbaru) const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                    const Text('Terbaru'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: UrutanKoleksi.judul,
                child: Row(
                  children: [
                    if (collection.urutan == UrutanKoleksi.judul) const Icon(Icons.check, size: 18),
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
                      label: Text(status.label(JenisMedia.anime)),
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
    if (collection.isLoading) {
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

    if (collection.errorMessage != null) {
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
        final progress = (entri.total != null && entri.total! > 0)
            ? (entri.progres / entri.total!).clamp(0.0, 1.0)
            : 0.0;
        final isSelesai = entri.status == StatusKoleksi.selesai;

        return GestureDetector(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      entri.coverUrl != null
                          ? Image.network(
                              entri.coverUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: Colors.grey[800],
                              width: double.infinity,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isSelesai && entri.total != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Material(
                            color: AppColors.primaryGreen,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () async {
                                final provider = context.read<CollectionProvider>();
                                await provider.incrementProgress(entri);
                                
                                if (!context.mounted) return;
                                final updated = provider.entries.firstWhere((e) => e.id == entri.id);
                                
                                if (updated.status == StatusKoleksi.selesai) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Selamat! Kamu telah menamatkan judul ini.')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Progres +1 berhasil.')),
                                  );
                                }
                              },
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.add, color: Colors.black, size: 18),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entri.judul,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${entri.progres}/${entri.total ?? "?"}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                color: AppColors.primaryGreen,
                minHeight: 3,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickMenu(BuildContext context, EntriKoleksi entri) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEntryPage(entri: entri),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                final collection = context.read<CollectionProvider>();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Koleksi?'),
                    content: Text('Apakah kamu yakin ingin menghapus "${entri.judul}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await collection.deleteEntry(entri);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berhasil dihapus.')),
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