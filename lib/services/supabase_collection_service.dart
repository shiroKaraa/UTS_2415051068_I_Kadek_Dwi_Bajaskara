import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_entry.dart';
import 'collection_data_source.dart';

class SupabaseCollectionService implements CollectionDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<EntriKoleksi>> getCollection(String deviceId) async {
    final response = await _supabase
        .from('koleksi')
        .select()
        .eq('device_id', deviceId)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((json) => EntriKoleksi.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<EntriKoleksi> createEntry(EntriKoleksi entri) async {
    final response = await _supabase
        .from('koleksi')
        .insert(entri.toJson())
        .select()
        .single();

    return EntriKoleksi.fromJson(response);
  }

  @override
  Future<EntriKoleksi> updateEntry(EntriKoleksi entri) async {
    final response = await _supabase
        .from('koleksi')
        .update(entri.toJson())
        .eq('id', entri.id!)
        .select()
        .single();

    return EntriKoleksi.fromJson(response);
  }

  @override
  Future<void> deleteEntry(int id) async {
    await _supabase.from('koleksi').delete().eq('id', id);
  }
  
}