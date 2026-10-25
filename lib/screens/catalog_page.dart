import 'package:flutter/material.dart';
import '../models/catalog_item.dart';
import '../models/media_type_enum.dart';
import 'catalog_detail_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyItems = [
      ItemKatalog(malId: 1, judul: 'Cowboy Bebop', jenis: JenisMedia.anime, total: 26, skor: 8.75),
      ItemKatalog(malId: 2, judul: 'One Piece', jenis: JenisMedia.manga, total: 1100, skor: 9.2),
      ItemKatalog(malId: 3, judul: 'Solo Leveling', jenis: JenisMedia.manhwa, total: 179, skor: 8.5),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog')),
      body: ListView.builder(
        itemCount: dummyItems.length,
        itemBuilder: (context, index) {
          final item = dummyItems[index];
          return ListTile(
            title: Text(item.displayTitle),
            subtitle: Text('${item.jenis.label} • ${item.total} ${item.jenis.satuanProgres}'),
            trailing: const Icon(Icons.chevron_right),
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