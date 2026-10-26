import '../models/collection_entry.dart';

abstract class CollectionDataSource {
  Future<List<EntriKoleksi>> getCollection(String deviceId);
  Future<EntriKoleksi> createEntry(EntriKoleksi entri);
  Future<EntriKoleksi> updateEntry(EntriKoleksi entri);

}