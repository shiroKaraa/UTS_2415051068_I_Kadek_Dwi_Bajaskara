import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/custom_label.dart';

class LabelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LabelKustom>> getLabels(String userId) async {
    final response = await _supabase
        .from('label_kustom')
        .select()
        .eq('user_id', userId)
        .order('nama', ascending: true);

    return (response as List)
        .map((json) => LabelKustom.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<LabelKustom> createLabel(LabelKustom label) async {
    final payload = {
      'nama': label.nama,
      'user_id': label.userId,
    };
    final response = await _supabase
        .from('label_kustom')
        .insert(payload)
        .select()
        .single();
    return LabelKustom.fromJson(response);
  }

  Future<LabelKustom> updateLabel(LabelKustom label) async {
    final response = await _supabase
        .from('label_kustom')
        .update(label.toJson())
        .eq('id', label.id!)
        .select()
        .single();
    return LabelKustom.fromJson(response);
  }

  Future<void> deleteLabel(int id, String userId) async {
    await _supabase
        .from('koleksi')
        .update({'label_id': null})
        .eq('label_id', id)
        .eq('user_id', userId);

    await _supabase
        .from('label_kustom')
        .delete()
        .eq('id', id);
  }
}