import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/custom_category.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<KategoriKustom>> getCategories(String deviceId) async {
    final response = await _supabase
        .from('kategori_kustom')
        .select()
        .eq('device_id', deviceId)
        .order('nama', ascending: true);

    return (response as List)
        .map((json) => KategoriKustom.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<KategoriKustom> createCategory(KategoriKustom category) async {
    final response = await _supabase
        .from('kategori_kustom')
        .insert(category.toJson())
        .select()
        .single();
    return KategoriKustom.fromJson(response);
  }

  Future<KategoriKustom> updateCategory(KategoriKustom category) async {
    final response = await _supabase
        .from('kategori_kustom')
        .update(category.toJson())
        .eq('id', category.id!)
        .select()
        .single();
    return KategoriKustom.fromJson(response);
  }

  Future<void> deleteCategory(int id) async {
    await _supabase.from('kategori_kustom').delete().eq('id', id);
  }
}