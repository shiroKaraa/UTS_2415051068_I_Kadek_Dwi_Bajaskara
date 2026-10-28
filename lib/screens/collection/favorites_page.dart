import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_sizes.dart';
import '../../providers/collection_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/collection_card.dart';
import 'collection_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();
    final favorites = collection.allEntries.where((e) => e.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Saya')),
      body: favorites.isEmpty
          ? EmptyView(
              title: 'Belum Ada Favorit',
              subtitle: 'Tandai anime atau manga favoritmu dengan ikon bintang.',
              icon: Icons.star_border_rounded,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 0.6,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final entri = favorites[index];
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
                  },
                );
              },
            ),
    );
  }
}