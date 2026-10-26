import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collection_provider.dart';
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
                  child: entri.coverUrl != null
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
            ],
          ),
        );
      },
    );
  }
}