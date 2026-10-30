import 'package:flutter/material.dart';
import '../../models/custom_category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<KategoriKustom> _categories = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _userId;
  
  List<KategoriKustom> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  String? get userId => _userId;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _categories = [];
    _hasLoaded = false;
    _errorMessage = null;
    notifyListeners();
    if (userId != null) {
      Future.microtask(() => fetchCategories());
    }
  }

  Future<void> fetchCategories() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _service.getCategories(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori: $e';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> createCategory(String nama, String satuan) async {
    final userId = _userId;
    if (userId == null) return false;
    try {
      final newCategory = await _service.createCategory(
        KategoriKustom(
          userId: userId,
          nama: nama,
          satuanProgres: satuan,
        ),
      );
      _categories.add(newCategory);
      _categories.sort((a, b) => a.nama.compareTo(b.nama));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah kategori: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(KategoriKustom category) async {
    try {
      final updated = await _service.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _categories[index] = updated;
        _categories.sort((a, b) => a.nama.compareTo(b.nama));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengedit kategori: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(KategoriKustom category) async {
    final id = category.id;
    if (id == null) return false;

    try {
      await _service.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus kategori: $e';
      notifyListeners();
      return false;
    }
  }
}