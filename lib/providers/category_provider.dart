import 'package:flutter/material.dart';
import '../../models/custom_category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<KategoriKustom> _categories = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _deviceId;

  List<KategoriKustom> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  void bindDevice(String? id) {
    if (_deviceId == id) return;
    _deviceId = id;
    _categories = [];
    _hasLoaded = false;
    _errorMessage = null;
    if (id != null) {
      Future.microtask(() => fetchCategories());
    }
  }

  Future<void> fetchCategories() async {
    if (_deviceId == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _service.getCategories(_deviceId!);
    } catch (e) {
      _errorMessage = 'Gagal memuat kategori: $e';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> createCategory(String nama, String satuan) async {
    if (_deviceId == null) return false;
    try {
      final newCategory = await _service.createCategory(
        KategoriKustom(deviceId: _deviceId!, nama: nama, satuanProgres: satuan),
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
    try {
      await _service.deleteCategory(category.id!);
      _categories.removeWhere((c) => c.id == category.id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus kategori: $e';
      notifyListeners();
      return false;
    }
  }
}