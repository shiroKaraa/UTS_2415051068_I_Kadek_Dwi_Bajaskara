import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/collection_entry.dart';
import '../providers/collection_provider.dart';
import 'edit_entry_page.dart';

class CollectionDetailPage extends StatelessWidget {
  final EntriKoleksi entri;

  const CollectionDetailPage({super.key, required this.entri});

  Future<void> _konfirmasiHapus(BuildContext context) async {
    final collection = context.read<CollectionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Koleksi?'),
        content: Text('Apakah kamu yakin ingin menghapus "${entri.judul}" dari koleksi?'),
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

    if (confirmed != true) return;

    final berhasil = await collection.deleteEntry(entri);

    if (!context.mounted) return;

    if (berhasil) {
      navigator.pop(); // Tutup halaman detail
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Berhasil dihapus dari koleksi.'),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entri.judul),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEntryPage(entri: entri),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _konfirmasiHapus(context),
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
                onPressed: () => _konfirmasiHapus(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus dari Koleksi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditEntryPage(entri: entri),
                    ),
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