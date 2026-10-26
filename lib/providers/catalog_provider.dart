import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/catalog_item.dart';
import '../models/media_type_enum.dart';
import '../services/anilist_service.dart';

class CatalogProvider extends ChangeNotifier {
  final AniListService _aniListService = AniListService();

  List<ItemKatalog> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasNextPage = true;
  int _currentPage = 1;

  String? _errorMessage;
  JenisMedia _selectedJenis = JenisMedia.anime;
  String _query = '';

  List<ItemKatalog> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;
  String? get errorMessage => _errorMessage;
  JenisMedia get selectedJenis => _selectedJenis;
  String get query => _query;

  // Tambahan Getter untuk Home
  List<ItemKatalog> get topAnime => _items.where((i) => i.jenis == JenisMedia.anime).take(10).toList();
  List<ItemKatalog> get topManga => _items.where((i) => i.jenis != JenisMedia.anime).take(10).toList();

  CatalogProvider() {
    fetchCatalog();
  }

  // Fungsi Pesan Error Ramah
  String _pesanError(Object e) {
    if (e is SocketException || e.toString().contains('ClientException')) {
      return 'Tidak bisa terhubung ke server. Periksa internet Anda lalu coba lagi.';
    }
    if (e is TimeoutException) {
      return 'Server terlalu lama merespons. Coba lagi.';
    }
    return 'Terjadi kesalahan saat memuat data.';
  }

  Future<void> fetchCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasNextPage = true;
    notifyListeners();

    try {
      final rawData = await _fetchData(_currentPage);
      _items = rawData.map((json) => ItemKatalog.fromAniList(json, _selectedJenis)).toList();
      if (rawData.length < 20) _hasNextPage = false;
    } catch (e) {
      _errorMessage = _pesanError(e);
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // loadMore, _fetchData, setJenis, setQuery, refresh (Sama seperti sebelumnya)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasNextPage || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final rawData = await _fetchData(nextPage);
      if (rawData.isEmpty) {
        _hasNextPage = false;
      } else {
        _currentPage = nextPage;
        _items.addAll(rawData.map((json) => ItemKatalog.fromAniList(json, _selectedJenis)));
        if (rawData.length < 20) _hasNextPage = false;
      }
    } catch (e) {
      debugPrint('Gagal memuat halaman berikutnya: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchData(int page) {
    if (_query.isEmpty) {
      return _aniListService.getTop(jenis: _selectedJenis, page: page);
    } else {
      return _aniListService.search(query: _query, jenis: _selectedJenis, page: page);
    }
  }

  void setJenis(JenisMedia jenis) {
    if (_selectedJenis == jenis) return;
    _selectedJenis = jenis;
    fetchCatalog();
  }

  void setQuery(String query) {
    _query = query;
    fetchCatalog();
  }

  Future<void> refresh() async {
    await fetchCatalog();
  }
}