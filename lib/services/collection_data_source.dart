import '../models/collection_entry.dart';

abstract class CollectionDataSource {
  Future<List<EntriKoleksi>> getCollection(String userId);
  Future<EntriKoleksi> createEntry(EntriKoleksi entri);
  Future<List<EntriKoleksi>> createEntries(List<EntriKoleksi> entries);
  Future<EntriKoleksi> updateEntry(EntriKoleksi entri);
  Future<void> deleteEntry(int id);
  Future<void> deleteAll(String userId);
  Future<void> deleteEntries(List<int> ids);
  Future<void> updateEntriesFields(List<int> ids, Map<String, dynamic> data);
  Future<int> countClaimableCollections(String deviceId);
  Future<bool> pingServer();
}