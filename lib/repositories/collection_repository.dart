import '../models/collection_entry.dart';
import '../services/collection_data_source.dart';

class CollectionRepository {
  final CollectionDataSource _dataSource;

  CollectionRepository(this._dataSource);

  Future<List<EntriKoleksi>> getCollection(String userId) {
    return _dataSource.getCollection(userId);
  }

  Future<EntriKoleksi> createEntry(EntriKoleksi entri) {
    return _dataSource.createEntry(entri);
  }

  Future<List<EntriKoleksi>> createEntries(List<EntriKoleksi> entries) {
    return _dataSource.createEntries(entries);
  }

  Future<EntriKoleksi> updateEntry(EntriKoleksi entri) {
    return _dataSource.updateEntry(entri);
  }

  Future<void> deleteEntry(int id) {
    return _dataSource.deleteEntry(id);
  }
}