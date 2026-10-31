import 'package:flutter_test/flutter_test.dart';
import 'package:tsuzuki/models/collection_entry.dart';
import 'package:tsuzuki/models/media_type_enum.dart';
import 'package:tsuzuki/models/status_collection_enum.dart';
import 'package:tsuzuki/providers/collection_provider.dart';
import 'package:tsuzuki/repositories/collection_repository.dart';
import 'package:tsuzuki/services/collection_data_source.dart';

class _FakeDataSource implements CollectionDataSource {
  @override
  Future<List<EntriKoleksi>> getCollection(String userId) async => [];
  @override
  Future<EntriKoleksi> createEntry(EntriKoleksi entri) async => entri;
  @override
  Future<List<EntriKoleksi>> createEntries(List<EntriKoleksi> entries) async => entries;
  @override
  Future<EntriKoleksi> updateEntry(EntriKoleksi entri) async => entri;
  @override
  Future<void> deleteEntry(int id) async {}
  @override
  Future<void> deleteAll(String userId) async {}
  @override
  Future<void> deleteEntries(List<int> ids) async {}
  @override
  Future<void> updateEntriesFields(List<int> ids, Map<String, dynamic> data) async {}
  @override
  Future<int> countClaimableCollections(String deviceId) async => 0;
  @override
  Future<bool> pingServer() async => true;
}

void main() {
  late CollectionProvider provider;

  setUp(() {
    provider = CollectionProvider(
      CollectionRepository(_FakeDataSource()),
    );
  });

  EntriKoleksi makeEntry({required int progres, int? total, required StatusKoleksi status}) {
    return EntriKoleksi(
      jenis: JenisMedia.anime,
      judul: 'Test',
      status: status,
      progres: progres,
      total: total,
    );
  }

  group('reconcileStatus', () {
    test('progres >= total → selesai', () {
      final e = makeEntry(progres: 24, total: 24, status: StatusKoleksi.sedang);
      final result = provider.reconcileStatus(e);
      expect(result.status, StatusKoleksi.selesai);
    });

    test('status selesai tapi progres < total → sedang', () {
      final e = makeEntry(progres: 12, total: 24, status: StatusKoleksi.selesai);
      final result = provider.reconcileStatus(e);
      expect(result.status, StatusKoleksi.sedang);
    });

    test('progres > 0 & direncanakan → sedang', () {
      final e = makeEntry(progres: 5, total: 24, status: StatusKoleksi.direncanakan);
      final result = provider.reconcileStatus(e);
      expect(result.status, StatusKoleksi.sedang);
    });

    test('total null → tidak berubah', () {
      final e = makeEntry(progres: 5, total: null, status: StatusKoleksi.direncanakan);
      final result = provider.reconcileStatus(e);
      expect(result.status, StatusKoleksi.direncanakan);
    });

    test('progres 0 & selesai → tidak berubah (tidak mungkin)', () {
      final e = makeEntry(progres: 0, total: 24, status: StatusKoleksi.selesai);
      final result = provider.reconcileStatus(e);
      expect(result.status, StatusKoleksi.selesai);
    });
  });
}