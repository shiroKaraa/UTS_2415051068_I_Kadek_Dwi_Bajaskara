import 'package:flutter/material.dart';
import '../models/catalog_item.dart';
import '../models/media_type_enum.dart';
import '../widgets/media_card.dart';
import '../widgets/responsive_grid.dart';
import 'catalog_detail_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyItems = [
      ItemKatalog(malId: 1, judul: 'Cowboy Bebop', jenis: JenisMedia.anime, total: 26, skor: 8.75, coverUrl: 'https://cdn.myanimelist.net/images/anime/4/19644.jpg'),
      ItemKatalog(malId: 2, judul: 'One Piece', jenis: JenisMedia.manga, total: 1100, skor: 9.2, coverUrl: 'https://cdn.myanimelist.net/images/manga/2/253146.jpg'),
      ItemKatalog(malId: 3, judul: 'Solo Leveling', jenis: JenisMedia.manhwa, total: 179, skor: 8.5, coverUrl: 'https://cdn.myanimelist.net/images/manga/3/222841.jpg'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: ResponsiveGrid(
        itemCount: dummyItems.length,
        itemBuilder: (context, index) {
          final item = dummyItems[index];
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
      ),
    );
  }
}