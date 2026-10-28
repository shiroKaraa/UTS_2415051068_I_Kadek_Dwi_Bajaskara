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
  int _requestGeneration = 0;
  String? _filterGenre;
  int? _filterTahun;
  List<ItemKatalog> _popularAnime = [];
  List<ItemKatalog> _popularManga = [];
  bool _isLoadingPopular = false;
  bool _hasFetchedPopular = false;
  bool _disposed = false;
  List<ItemKatalog> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;
  String? get errorMessage => _errorMessage;
  JenisMedia get selectedJenis => _selectedJenis;
  String get query => _query;
  String? get filterGenre => _filterGenre;
  int? get filterTahun => _filterTahun;
  List<ItemKatalog> get topAnime => _popularAnime;
  List<ItemKatalog> get topManga => _popularManga;
  bool get isLoadingPopular => _isLoadingPopular;

  CatalogProvider() {
    fetchCatalog();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

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
    final gen = ++_requestGeneration;
    _isLoading = true;
    _isLoadingMore = false;
    _errorMessage = null;
    _currentPage = 1;
    _hasNextPage = true;
    _safeNotify();

    try {
      final rawData = await _fetchData(_currentPage);
      if (gen != _requestGeneration) return;
      
      _items = rawData.map((json) => ItemKatalog.fromAniList(json, _selectedJenis)).toList();
      if (rawData.length < 20) _hasNextPage = false;
    } catch (e) {
      if (gen != _requestGeneration) return;
      _errorMessage = _pesanError(e);
      _items = [];
      _hasNextPage = false;
    } finally {
      if (gen == _requestGeneration) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasNextPage || _isLoading) return;

    final gen = _requestGeneration;
    _isLoadingMore = true;
    _safeNotify();
    
    try {
      final nextPage = _currentPage + 1;
      final rawData = await _fetchData(nextPage);
      if (gen != _requestGeneration) return;

      if (rawData.isEmpty) {
        _hasNextPage = false;
      } else {
        _currentPage = nextPage;
        final newItems = rawData.map((json) => ItemKatalog.fromAniList(json, _selectedJenis)).toList();
        
        final existingIds = _items.map((e) => e.malId).toSet();
        final uniqueNewItems = newItems.where((e) => !existingIds.contains(e.malId)).toList();
        
        _items.addAll(uniqueNewItems);
        
        if (rawData.length < 20) _hasNextPage = false;
      }
    } catch (e) {
      debugPrint('Gagal memuat halaman berikutnya: $e');
    } finally {
      _isLoadingMore = false;
      if (gen == _requestGeneration) _safeNotify();
    }
  }

  Future<void> fetchPopularHome() async {
    if (_hasFetchedPopular) return;
    if (_isLoadingPopular) return;

    _isLoadingPopular = true;
    _safeNotify();

    try {
      final results = await Future.wait([
        _aniListService.getTop(jenis: JenisMedia.anime, page: 1)
            .catchError((e) {
              debugPrint('Gagal muat anime populer: $e');
              return <Map<String, dynamic>>[];
            }),
        _aniListService.getTop(jenis: JenisMedia.manga, page: 1)
            .catchError((e) {
              debugPrint('Gagal muat manga populer: $e');
              return <Map<String, dynamic>>[];
            }),
      ]);
      
      _popularAnime = results[0].map((json) => ItemKatalog.fromAniList(json, JenisMedia.anime)).toList();
      _popularManga = results[1].map((json) => ItemKatalog.fromAniList(json, JenisMedia.manga)).toList();
      
      if (_popularAnime.isNotEmpty || _popularManga.isNotEmpty) {
        _hasFetchedPopular = true;
      }
    } catch (e) {
      debugPrint('Gagal memuat data populer: $e');
    } finally {
      _isLoadingPopular = false;
      _safeNotify();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchData(int page) {
    if (_query.isEmpty) {
      return _aniListService.getTop(
        jenis: _selectedJenis, 
        page: page,
        genre: _filterGenre,
        tahun: _filterTahun,
      );
    } else {
      return _aniListService.search(
        query: _query, 
        jenis: _selectedJenis, 
        page: page,
        genre: _filterGenre,
        tahun: _filterTahun,
      );
    }
  }

  void setJenis(JenisMedia jenis) {
    if (_selectedJenis == jenis) return;
    _selectedJenis = jenis;
    fetchCatalog();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    fetchCatalog();
  }

  void setFilters({String? genre, int? tahun}) {
    _filterGenre = genre;
    _filterTahun = tahun;
    fetchCatalog();
  }

  void clearFilters() {
    _filterGenre = null;
    _filterTahun = null;
    _query = ''; 
    fetchCatalog();
  }

  Future<void> refresh() async {
    _hasFetchedPopular = false;
    await Future.wait([
      fetchCatalog(),
      fetchPopularHome(),
    ]);
  }
}