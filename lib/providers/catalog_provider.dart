import 'package:flutter/material.dart';
import '../models/catalog_item.dart';
import '../models/media_type_enum.dart';

class CatalogProvider extends ChangeNotifier {
  List<ItemKatalog> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  JenisMedia? _selectedJenis; 

  List<ItemKatalog> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  JenisMedia? get selectedJenis => _selectedJenis;

  CatalogProvider() {
    // Karena belum ada API, kita nemakai data dummy dulu.
    _loadDummyData();
  }

  Future<void> _loadDummyData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      _items = [
        ItemKatalog(
          malId: 1,
          judul: 'Cowboy Bebop',
          jenis: JenisMedia.anime,
          total: 26,
          skor: 8.75,
          coverUrl: 'https://cdn.myanimelist.net/images/anime/4/19644.jpg',
        ),
        ItemKatalog(
          malId: 2,
          judul: 'One Piece',
          jenis: JenisMedia.manga,
          total: 1100,
          skor: 9.2,
          coverUrl: 'https://cdn.myanimelist.net/images/manga/2/253146.jpg',
        ),
        ItemKatalog(
          malId: 3,
          judul: 'Solo Leveling',
          jenis: JenisMedia.manhwa,
          total: 179,
          skor: 8.5,
          coverUrl: 'https://cdn.myanimelist.net/images/manga/3/222841.jpg',
        ),
      ];
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data: $e';
    }
    notifyListeners();
  }

  void setFilter(JenisMedia? jenis) {
    if (_selectedJenis == jenis) return; 
    _selectedJenis = jenis;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadDummyData();
  }
}