import 'package:flutter/material.dart';
import '../models/collection_entry.dart';
import '../models/media_type_enum.dart';
import '../models/status_collection_enum.dart';
import 'collection_detail_page.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyEntries = [
      EntriKoleksi(
        id: 1,
        deviceId: '2611234567',
        jenis: JenisMedia.anime,
        judul: 'Cowboy Bebop',
        status: StatusKoleksi.sedang,
        progres: 10,
        total: 26,
        rating: 4,
        catatan: 'Serial legendaris.',
      ),
      EntriKoleksi(
        id: 2,
        deviceId: '2611234567',
        jenis: JenisMedia.manhwa,
        judul: 'Solo Leveling',
        status: StatusKoleksi.selesai,
        progres: 179,
        total: 179,
        rating: 5,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi')),
      body: ListView.builder(
        itemCount: dummyEntries.length,
        itemBuilder: (context, index) {
          final entri = dummyEntries[index];
          return ListTile(
            title: Text(entri.judul),
            subtitle: Text('${entri.status.label(entri.jenis)} • ${entri.progres}/${entri.total}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollectionDetailPage(entri: entri),
                ),
              );
            },
          );
        },
      ),
    );
  }
}