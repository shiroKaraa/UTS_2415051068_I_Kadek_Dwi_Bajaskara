import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/collection_entry.dart';
import 'collection_data_source.dart';

class SupabaseCollectionService implements CollectionDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const int _pageSize = 500;
  static const Duration _timeout = Duration(seconds: 15);

  String _requireUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Pengguna belum login.');
    return user.id;
  }

  @override
  Future<List<EntriKoleksi>> getCollection(String userId) async {
    final all = <EntriKoleksi>[];
    int from = 0;

    while (true) {
      final response = await _supabase
          .from('koleksi')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: true)
          .range(from, from + _pageSize - 1)
          .timeout(_timeout,
              onTimeout: () => throw TimeoutException('Koneksi lambat / Offline'));

      final batch = <EntriKoleksi>[];
      for (final json in response as List) {
        try {
          batch.add(EntriKoleksi.fromJson(json as Map<String, dynamic>));
        } catch (e) {
          debugPrint('Baris koleksi dilewati: $e');
        }
      }

      all.addAll(batch);
      if (batch.length < _pageSize) break;
      from += _pageSize;
    }
    return all;
  }

  @override
  Future<EntriKoleksi> createEntry(EntriKoleksi entri) async {
    final userId = _requireUserId();
    final payload = {...entri.toJson(), 'user_id': userId};
    
    try {
      final response = await _supabase
          .from('koleksi')
          .insert(payload)
          .select()
          .single()
          .timeout(_timeout, onTimeout: () => throw TimeoutException('Simpan timeout'));
      return EntriKoleksi.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw Exception('Anime/komik ini sudah ada di koleksimu.');
      rethrow;
    }
  }

  @override
  Future<List<EntriKoleksi>> createEntries(List<EntriKoleksi> entries) async {
    if (entries.isEmpty) return [];
    final userId = _requireUserId();
    final payload = entries.map((e) => {...e.toJson(), 'user_id': userId}).toList();
    try {
      final response = await _supabase
          .from('koleksi')
          .insert(payload)
          .select()
          .timeout(_timeout, onTimeout: () => throw TimeoutException('Impor timeout'));
      return (response as List).map((json) => EntriKoleksi.fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Impor gagal: Ada judul yang sudah ada di koleksi. Tidak ada data yang tersimpan.');
      }
      rethrow;
    }
  }

  @override
  Future<EntriKoleksi> updateEntry(EntriKoleksi entri) async {
    final id = entri.id;
    if (id == null) {
      throw Exception('Gagal update: Entri belum tersimpan (ID kosong).');
    }
    final userId = _requireUserId();
    final payload = <String, dynamic>{
      'jenis': entri.jenis.name,
      'label_id': entri.labelId,
      'external_id': entri.externalId,
      'judul': entri.judul,
      'cover_url': entri.coverUrl,
      'status': entri.status.name,
      'progres': entri.progres,
      'total': entri.total,
      'rating': entri.rating,
      'catatan': entri.catatan,
      'is_favorite': entri.isFavorite,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await _supabase
          .from('koleksi')
          .update(payload)
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .maybeSingle()
          .timeout(
            _timeout,
            onTimeout: () => throw TimeoutException('Update timeout'),
          );
      if (response == null) {
        throw Exception(
          'Entri tidak ditemukan di server. Mungkin sudah dihapus dari '
          'perangkat lain. Coba refresh koleksi.',
        );
      }
      return EntriKoleksi.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('updateEntry PostgrestException: code=${e.code} msg=${e.message}');
      if (e.code == 'PGRST116') {
        throw Exception('Entri tidak ditemukan atau tidak bisa diakses.');
      }
      if (e.code == '42501') {
        throw Exception('Tidak diizinkan mengubah entri ini.');
      }
      throw Exception('Gagal menyimpan: ${e.message}');
    }
  }

  @override
  Future<void> deleteEntry(int id) async {
    final userId = _requireUserId();
    await _supabase
        .from('koleksi')
        .delete()
        .eq('id', id)
        .eq('user_id', userId)
        .timeout(_timeout, onTimeout: () => throw TimeoutException('Delete timeout'));
  }

  @override
  Future<void> deleteAll(String userId) async {
    await _supabase
        .from('koleksi')
        .delete()
        .eq('user_id', userId)
        .timeout(_timeout, onTimeout: () => throw TimeoutException('Delete all timeout'));
  }

  @override
  Future<void> deleteEntries(List<int> ids) async {
    if (ids.isEmpty) return;
    final userId = _requireUserId();
    await _supabase
        .from('koleksi')
        .delete()
        .inFilter('id', ids)
        .eq('user_id', userId)
        .timeout(_timeout,
            onTimeout: () => throw TimeoutException('Bulk delete timeout'));
  }

  @override
  Future<void> updateEntriesFields(
      List<int> ids, Map<String, dynamic> data) async {
    if (ids.isEmpty) return;
    final userId = _requireUserId();
    final payload = Map<String, dynamic>.from(data)
      ..remove('user_id')
      ..remove('device_id');
    await _supabase
        .from('koleksi')
        .update(payload)
        .inFilter('id', ids)
        .eq('user_id', userId)
        .timeout(_timeout,
            onTimeout: () => throw TimeoutException('Bulk update timeout'));
  }

  @override
  Future<int> countClaimableCollections(String deviceId) async {
    try {
      final response = await _supabase
          .from('koleksi')
          .select('id')
          .eq('device_id', deviceId)
          .isFilter('user_id', null)
          .count(CountOption.exact)
          .timeout(const Duration(seconds: 5));
      return response.count;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> pingServer() async {
    try {
      await _supabase
          .from('koleksi')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (_) {
      return false;
    }
  }
}