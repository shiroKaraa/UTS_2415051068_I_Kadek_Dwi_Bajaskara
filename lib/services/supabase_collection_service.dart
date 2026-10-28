import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/collection_entry.dart';
import 'collection_data_source.dart';

class SupabaseCollectionService implements CollectionDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _requireUserId() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Pengguna belum login.');
    }
    return user.id;
  }

  @override
  Future<List<EntriKoleksi>> getCollection(String userId) async {
    final response = await _supabase
        .from('koleksi')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('Koneksi lambat / Offline'),
        );

    return (response as List)
        .map((json) => EntriKoleksi.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EntriKoleksi> createEntry(EntriKoleksi entri) async {
    final userId = _requireUserId();
    final payload = {
      ...entri.toJson(),
      'user_id': userId,
    };
    final response = await _supabase
        .from('koleksi')
        .insert(payload)
        .select()
        .single();

    return EntriKoleksi.fromJson(response);
  }

  @override
  Future<List<EntriKoleksi>> createEntries(List<EntriKoleksi> entries) async {
    if (entries.isEmpty) return [];
    final userId = _requireUserId();
    final payload = entries
        .map((e) => {
              ...e.toJson(),
              'user_id': userId,
            })
        .toList();

    final response =
        await _supabase.from('koleksi').insert(payload).select();

    return (response as List)
        .map((json) => EntriKoleksi.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EntriKoleksi> updateEntry(EntriKoleksi entri) async {
    final userId = _requireUserId();
    final payload = entri.toJson()..remove('user_id');
    final response = await _supabase
        .from('koleksi')
        .update(payload)
        .eq('id', entri.id!)
        .eq('user_id', userId)
        .select()
        .single();

    return EntriKoleksi.fromJson(response);
  }

  @override
  Future<void> deleteEntry(int id) async {
    final userId = _requireUserId();
    await _supabase
        .from('koleksi')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}