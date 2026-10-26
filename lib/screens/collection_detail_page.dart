import 'package:flutter/material.dart';
import '../models/collection_entry.dart';

class CollectionDetailPage extends StatelessWidget {
  final EntriKoleksi entri;

  const CollectionDetailPage({super.key, required this.entri});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entri.judul),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur edit akan dibuat di Tahap 20')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur hapus akan dibuat di Tahap 22')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jenis: ${entri.jenis.label}'),
            Text('Status: ${entri.status.label(entri.jenis)}'),
            Text('Progres: ${entri.progres} / ${entri.total ?? "?"}'),
            if (entri.rating != null) Text('Rating: ${'⭐' * entri.rating!}'),
            const Divider(height: 32),
            const Text('Catatan:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(entri.catatan ?? 'Tidak ada catatan.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur edit akan dibuat di Tahap 20')),
                  );
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Edit Entri Ini'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}