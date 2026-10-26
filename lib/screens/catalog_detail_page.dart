import 'package:flutter/material.dart';
import '../models/catalog_item.dart';

class CatalogDetailPage extends StatelessWidget {
  final ItemKatalog item;

  const CatalogDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.displayTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.coverUrl != null)
              Center(
                child: Hero(
                  tag: 'poster_${item.malId}', 
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.coverUrl!,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            Text(item.displayTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(item.jenis.label)),
                const SizedBox(width: 8),
                if (item.skor != null) Chip(label: Text('⭐ ${item.skor}')),
                const SizedBox(width: 8),
                if (item.total != null) Chip(label: Text('${item.total} ${item.jenis.satuanProgres}')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Sinopsis:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item.sinopsis ?? 'Tidak ada sinopsis.'),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur tambah koleksi akan dibuat di Tahap 19')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah ke Koleksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}