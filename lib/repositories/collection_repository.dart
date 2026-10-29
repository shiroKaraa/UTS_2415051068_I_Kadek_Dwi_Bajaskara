import '../../models/collection_entry.dart';
import '../services/collection_data_source.dart';

class CollectionRepository {
  final CollectionDataSource _dataSource;

  CollectionRepository(this._dataSource);

  Future<List<EntriKoleksi>> getCollection(String userId) => _dataSource.getCollection(userId);
  Future<EntriKoleksi> createEntry(EntriKoleksi entri) => _dataSource.createEntry(entri);
  Future<List<EntriKoleksi>> createEntries(List<EntriKoleksi> entries) => _dataSource.createEntries(entries);
  Future<EntriKoleksi> updateEntry(EntriKoleksi entri) => _dataSource.updateEntry(entri);
  Future<void> deleteEntry(int id) => _dataSource.deleteEntry(id);
  Future<void> deleteAll(String userId) => _dataSource.deleteAll(userId);
  Future<int> countClaimableCollections(String deviceId) => _dataSource.countClaimableCollections(deviceId);
  Future<bool> pingServer() => _dataSource.pingServer();
}