import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
import '../models/status_collection_enum.dart';
import '../core/app_colors.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import 'collection_detail_page.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => collection.refresh(),
          ),
        ],
      ),
      body: _buildContent(context, collection),
    );
  }

  Widget _buildContent(BuildContext context, CollectionProvider collection) {
    if (collection.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: Colors.grey[800],
                              width: double.infinity,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),

                      // Gradasi gelap di bawah
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

                      // Tombol +1
                      if (!isSelesai && entri.total != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Material(
                            color: AppColors.primaryGreen,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<CollectionProvider>()
                                    .incrementProgress(entri);
                              },
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(Icons.add,
                                    color: Colors.black, size: 18),
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
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                color: AppColors.primaryGreen,
                minHeight: 3,
              ),
            ],
          ),
        );
      },
    );
  }
}