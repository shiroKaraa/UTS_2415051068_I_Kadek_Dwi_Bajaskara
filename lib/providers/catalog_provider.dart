import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import '../../models/catalog_item.dart';
import '../../models/media_type_enum.dart';
import '../../services/anilist_service.dart';

enum UrutanKatalog { populer, skor, terbaru, judul, relevan }
enum TipeError { network, rateLimit, api, unknown }

class CatalogProvider extends ChangeNotifier {
  final AniListService _service = AniListService();
  
  List<ItemKatalog> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasNextPage = true;
  int _currentPage = 1;
  int _totalResults = 0;
  
  TipeError? _errorType;
  String? _errorMessage;
  String? _loadMoreError;
  
  JenisMedia _selectedJenis = JenisMedia.anime;
  String _query = '';
  int _requestGeneration = 0;
  
  List<String> _filterGenres = [];
  int? _filterTahun;
  String? _filterStatus;
  UrutanKatalog _urutan = UrutanKatalog.populer;

  List<String> _availableGenres = [];

  List<ItemKatalog> _popularAnime = [];
  List<ItemKatalog> _popularManga = [];
  bool _isLoadingPopular = false;
  bool _hasFetchedPopular = false;
  String? _popularError;

  bool _disposed = false;

  UnmodifiableListView<ItemKatalog> get items => UnmodifiableListView(_items);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;
  int get totalResults => _totalResults;
  TipeError? get errorType => _errorType;
  String? get errorMessage => _errorMessage;
  String? get loadMoreError => _loadMoreError;
  JenisMedia get selectedJenis => _selectedJenis;
  String get query => _query;
  List<String> get filterGenres => _filterGenres;
  int? get filterTahun => _filterTahun;
  String? get filterStatus => _filterStatus;
  UrutanKatalog get urutan => _urutan;
  List<String> get availableGenres => _availableGenres;

  List<ItemKatalog> get topAnime => _popularAnime;
  List<ItemKatalog> get topManga => _popularManga;
  bool get isLoadingPopular => _isLoadingPopular;
  String? get popularError => _popularError;

  bool get hasActiveFilters => _filterGenres.isNotEmpty || _filterTahun != null || _filterStatus != null;
  bool get hasQuery => _query.isNotEmpty;

  CatalogProvider() {
    _fetchAvailableGenres();
  }

  @override
  void dispose() {
    _disposed = true;
    _service.dispose();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _fetchAvailableGenres() async {
    if (_availableGenres.isNotEmpty) return;
    _availableGenres = await _service.fetchGenres();
    _safeNotify();
  }

  String _getSortParam() {
    if (_query.isNotEmpty && _urutan == UrutanKatalog.populer) return 'SEARCH_MATCH';
    
    switch (_urutan) {
      case UrutanKatalog.populer: return 'POPULARITY_DESC';
      case UrutanKatalog.skor: return 'SCORE_DESC';
      case UrutanKatalog.terbaru: return 'START_DATE_DESC';
      case UrutanKatalog.judul: return 'TITLE_ROMAJI';
      case UrutanKatalog.relevan: return 'SEARCH_MATCH';
    }
  }

  Future<void> fetchCatalog() async {
    final gen = ++_requestGeneration;
    _isLoading = true;
    _isLoadingMore = false;
    _errorType = null;
    _errorMessage = null;
    _loadMoreError = null;
    _currentPage = 1;
    _hasNextPage = true;
    _totalResults = 0;
    _safeNotify();

    try {
      final result = await _service.fetchPage(
        jenis: _selectedJenis,
        page: _currentPage,
        searchQuery: _query.isEmpty ? null : _query,
        genres: _filterGenres,
        tahun: _filterTahun,
        status: _filterStatus,
        sort: _getSortParam(),
      );
      if (gen != _requestGeneration) return;
      
      _items = result.media.map((json) => ItemKatalog.fromAniList(json, _selectedJenis)).toList();
      _hasNextPage = result.hasNextPage;
      _totalResults = result.total;
    } catch (e) {
      if (gen != _requestGeneration) return;
      _handleError(e);
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
    if (_isLoadingMore || !_hasNextPage || _isLoading || _loadMoreError != null) return;

    final gen = _requestGeneration;
    _isLoadingMore = true;
    _safeNotify();
    
    try {
      final nextPage = _currentPage + 1;
      final result = await _service.fetchPage(
        jenis: _selectedJenis,
        page: nextPage,
        searchQuery: _query.isEmpty ? null : _query,
        genres: _filterGenres,
        tahun: _filterTahun,
        status: _filterStatus,
        sort: _getSortParam(),
      );
      if (gen != _requestGeneration) return;

      if (result.media.isEmpty) {
        _hasNextPage = false;
      } else {
        _currentPage = nextPage;
        final newItems = result.media.map((json) => ItemKatalog.fromAniList(json, _selectedJenis)).toList();
        final existingIds = _items.map((e) => e.anilistId).toSet();
        final uniqueNewItems = newItems.where((e) => !existingIds.contains(e.anilistId)).toList();
        _items.addAll(uniqueNewItems);
        _hasNextPage = result.hasNextPage;
      }
    } catch (e) {
      if (gen == _requestGeneration) {
        _handleLoadMoreError(e);
      }
    } finally {
      if (gen == _requestGeneration) {
        _isLoadingMore = false;
        _safeNotify();
      }
    }
  }

  void retryLoadMore() {
    _loadMoreError = null;
    loadMore();
  }

  void _handleError(Object e) {
    if (e is RateLimitException) {
      _errorType = TipeError.rateLimit;
      _errorMessage = 'Terlalu banyak permintaan. Tunggu sebentar.';
    } else if (e is NetworkException) {
      _errorType = TipeError.network;
      _errorMessage = 'Tidak ada koneksi internet.';
    } else if (e is ApiException) {
      _errorType = TipeError.api;
      _errorMessage = 'Terjadi kesalahan server: ${e.message}';
    } else {
      _errorType = TipeError.unknown;
      _errorMessage = 'Terjadi kesalahan tidak diketahui.';
    }
  }

  void _handleLoadMoreError(Object e) {
    if (e is RateLimitException) {
      _loadMoreError = 'Batas permintaan tercapai. Coba lagi nanti.';
    } else if (e is NetworkException) {
      _loadMoreError = 'Koneksi terputus. Ketuk untuk coba lagi.';
    } else {
      _loadMoreError = 'Gagal memuat. Ketuk untuk coba lagi.';
    }
  }

  Future<void> fetchPopularHome({bool forceRefresh = false}) async {
    if (forceRefresh) _hasFetchedPopular = false;
    if (_hasFetchedPopular || _isLoadingPopular) return;

    _isLoadingPopular = true;
    _popularError = null;
    _safeNotify();

    try {
      final results = await Future.wait([
        _service.fetchPage(jenis: JenisMedia.anime, page: 1).catchError((_) => AniListResult(media: [], hasNextPage: false, total: 0)),
        _service.fetchPage(jenis: JenisMedia.manga, page: 1).catchError((_) => AniListResult(media: [], hasNextPage: false, total: 0)),
      ]);
      
      _popularAnime = results[0].media.map((json) => ItemKatalog.fromAniList(json, JenisMedia.anime)).toList();
      _popularManga = results[1].media.map((json) => ItemKatalog.fromAniList(json, JenisMedia.manga)).toList();
      
      if (_popularAnime.isEmpty && _popularManga.isEmpty) {
        _popularError = 'Gagal memuat data populer.';
      } else {
        _hasFetchedPopular = true;
      }
    } catch (e) {
      _popularError = 'Gagal memuat data populer.';
    } finally {
      _isLoadingPopular = false;
      _safeNotify();
    }
  }

  void setJenis(JenisMedia jenis) {
    if (_selectedJenis == jenis) return;
    _selectedJenis = jenis;
    fetchCatalog();
  }

  void setQuery(String query) {
    final trimmed = query.trim();
    if (_query == trimmed) return;
    _query = trimmed;
    fetchCatalog();
  }

  void setFilters({
    List<String>? genres,
    int? tahun,
    String? status,
    UrutanKatalog? urutan,
  }) {
    bool changed = false;
    if (genres != null && !_listEquals(genres, _filterGenres)) { _filterGenres = genres; changed = true; }
    if (tahun != _filterTahun) { _filterTahun = tahun; changed = true; }
    if (status != _filterStatus) { _filterStatus = status; changed = true; }
    if (urutan != null && urutan != _urutan) { _urutan = urutan; changed = true; }
    
    if (changed) fetchCatalog();
  }

  void clearFilters() {
    _filterGenres = [];
    _filterTahun = null;
    _filterStatus = null;
    _urutan = UrutanKatalog.populer;
    fetchCatalog();
  }

  void clearAll() {
    _filterGenres = [];
    _filterTahun = null;
    _filterStatus = null;
    _query = '';
    _urutan = UrutanKatalog.populer;
    fetchCatalog();
  }

  Future<void> refresh() async {
    await fetchCatalog();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) { if (a[i] != b[i]) return false; }
    return true;
  }
}