import '../models/collection_entry.dart';
import '../services/collection_data_source.dart';

class CollectionRepository {
  final CollectionDataSource _dataSource;

  CollectionRepository(this._dataSource);

  Future<List<EntriKoleksi>> getCollection(String deviceId) {
    return _dataSource.getCollection(deviceId);
  }

  Future<EntriKoleksi> createEntry(EntriKoleksi entri) {
    return _dataSource.createEntry(entri);
  }

  Future<EntriKoleksi> updateEntry(EntriKoleksi entri) {
    return _dataSource.updateEntry(entri);
  }
  
}