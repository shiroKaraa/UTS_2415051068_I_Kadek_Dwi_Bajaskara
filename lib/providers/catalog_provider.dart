import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/catalog_item.dart';
import '../../models/media_type_enum.dart';
import '../../services/anilist_service.dart';

enum UrutanKatalog { populer, skor, terbaru, judul, relevan }
enum TipeError { network, rateLimit, api, unknown }

class CatalogProvider extends ChangeNotifier {
  final AniListService _service = AniListService();
  String get _cacheKeyPopular => 'cache_popular_home_${_isNsfwEnabled ? 'nsfw' : 'sfw'}';
  static const Duration _cacheTtl = Duration(minutes: 30);
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
  bool _isNsfwEnabled = false;
  bool _isListView = false;
  bool get isListView => _isListView;
  List<String> _filterGenres = [];
  List<String> _filterTags = [];
  int? _filterTahun;
  String? _filterStatus;
  UrutanKatalog _urutan = UrutanKatalog.populer;
  int? _filterSkorMin;
  int? get filterSkorMin => _filterSkorMin;
  List<String> _availableGenres = [];
  bool _isLoadingGenres = false;
  bool _genresFromFallback = false;

  final List<String> _hardcodedGenres = [
    'Action', 'Adventure', 'Comedy', 'Drama', 'Ecchi', 'Fantasy', 
    'Horror', 'Mahou Shoujo', 'Mecha', 'Music', 'Mystery', 'Psychological', 
    'Romance', 'Sci-Fi', 'Slice of Life', 'Sports', 'Supernatural', 'Thriller'
  ];
  
  final List<String> _fallbackTags = [
    "Boys' Love", "Girls' Love", "Male Harem", "Female Harem", "Time Manipulation", 
    "Time Skip", "Time Loop", "Isekai", "Magic", "Martial Arts", "Super Power", 
    "Historical", "Video Games", "Gender Bending"
  ];

  List<String> _availableTags = [];
  bool _isLoadingTags = false;
  bool _tagsFromFallback = false;
  List<String> get availableTags => _availableTags;
  bool get isLoadingTags => _isLoadingTags;

  List<ItemKatalog> _popularAnime = [];
  List<ItemKatalog> _popularManga = [];
  bool _isLoadingPopular = false;
  bool _hasFetchedPopular = false;
  String? _popularError;
  bool _disposed = false;
  int _popularGen = 0;
  
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
  List<String> get filterTags => _filterTags;
  int? get filterTahun => _filterTahun;
  String? get filterStatus => _filterStatus;
  UrutanKatalog get urutan => _urutan;
  List<String> get availableGenres => _availableGenres;
  bool get isLoadingGenres => _isLoadingGenres;
  List<ItemKatalog> get topAnime => _popularAnime;
  List<ItemKatalog> get topManga => _popularManga;
  bool get isLoadingPopular => _isLoadingPopular;
  String? get popularError => _popularError;

  bool get hasActiveFilters =>
    _filterGenres.isNotEmpty || _filterTags.isNotEmpty ||
    _filterTahun != null || _filterStatus != null || _filterSkorMin != null;

  bool get hasAnyActiveFilters => hasActiveFilters || _query.isNotEmpty;

  CatalogProvider();

  @override
  void dispose() {
    _disposed = true;
    _service.dispose();
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void syncNsfwSetting(bool enabled) {
    if (_isNsfwEnabled == enabled) return;
    _isNsfwEnabled = enabled;
    _hasFetchedPopular = false;
    _popularAnime = [];
    _popularManga = [];
    _availableTags = [];
    _tagsFromFallback = false;
    Future.microtask(() {
      if (_disposed) return;
      fetchCatalog();
      fetchPopularHome(forceRefresh: true);
    });
  }

  Future<void> ensureGenres() async {
    if (_availableGenres.isNotEmpty && !_genresFromFallback) return;
    if (_isLoadingGenres) return;
    _isLoadingGenres = true;
    _safeNotify();
    try {
      final apiGenres = await _service.fetchGenres();
      if (apiGenres.isNotEmpty) {
        _availableGenres = apiGenres.where((g) => g != 'Hentai').toList()..sort();
        _genresFromFallback = false;
      } else {
        _availableGenres = List.from(_hardcodedGenres)..sort();
        _genresFromFallback = true;
      }
    } catch (_) {
      _availableGenres = List.from(_hardcodedGenres)..sort();
      _genresFromFallback = true;
    } finally {
      _isLoadingGenres = false;
      _safeNotify();
    }
  }

  Future<void> ensureTags() async {
    if (_availableTags.isNotEmpty && !_tagsFromFallback) return;
    if (_isLoadingTags) return;
    _isLoadingTags = true;
    _safeNotify();
    try {
      final apiTags = await _service.fetchTags(isAdult: _isNsfwEnabled);
      if (apiTags.isNotEmpty) {
        _availableTags = apiTags;
        _tagsFromFallback = false;
      } else {
        _availableTags = List.from(_fallbackTags)..sort();
        _tagsFromFallback = true;
      }
    } catch (_) {
      _availableTags = List.from(_fallbackTags)..sort();
      _tagsFromFallback = true;
    } finally {
      _isLoadingTags = false;
      _safeNotify();
    }
  }

  String _getSortParam() {
    switch (_urutan) {
      case UrutanKatalog.populer:
        return 'POPULARITY_DESC';
      case UrutanKatalog.skor:
        return 'SCORE_DESC';
      case UrutanKatalog.terbaru:
        return 'START_DATE_DESC';
      case UrutanKatalog.judul:
        return 'TITLE_ROMAJI';
      case UrutanKatalog.relevan:
        return 'SEARCH_MATCH';
    }
  }

  Future<AniListResult> _fetch(int page) {
    return _service.fetchPage(
      jenis: _selectedJenis,
      page: page,
      searchQuery: _query.isEmpty ? null : _query,
      genres: _filterGenres,
      tags: _filterTags,
      tahun: _filterTahun,
      status: _filterStatus,
      sort: _getSortParam(),
      skorMin: _filterSkorMin,
      isAdult: _isNsfwEnabled,
    );
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
    _items = [];
    _totalResults = 0;
    _safeNotify();

    try {
      final result = await _fetch(_currentPage);
      if (gen != _requestGeneration) return;

      _items = result.media
          .map((json) => ItemKatalog.fromAniList(json, _selectedJenis))
          .toList();
      _hasNextPage = result.hasNextPage;
      _totalResults = result.total;
    } catch (e) {
      if (gen != _requestGeneration) return;
      _handleError(e);
      if (_items.isEmpty) _hasNextPage = false;
    } finally {
      if (gen == _requestGeneration) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  Future<void> refresh() async {
    final gen = ++_requestGeneration;
    _isLoading = false;
    _isLoadingMore = false;
    _errorType = null;
    _errorMessage = null;
    _loadMoreError = null;
    _currentPage = 1;
    _hasNextPage = true;

    try {
      final result = await _fetch(_currentPage);
      if (gen != _requestGeneration) return;
      _items = result.media
          .map((json) => ItemKatalog.fromAniList(json, _selectedJenis))
          .toList();
      _hasNextPage = result.hasNextPage;
      _totalResults = result.total;
    } catch (e) {
      if (gen != _requestGeneration) return;
      _handleError(e);
    } finally {
      if (gen == _requestGeneration) {
        _safeNotify();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore ||
        !_hasNextPage ||
        _isLoading ||
        _loadMoreError != null) {
      return;
    }

    final gen = _requestGeneration;
    _isLoadingMore = true;
    _safeNotify();

    try {
      final nextPage = _currentPage + 1;
      final result = await _fetch(nextPage);
      if (gen != _requestGeneration) return;

      if (result.media.isEmpty) {
        _hasNextPage = false;
      } else {
        _currentPage = nextPage;
        final newItems = result.media
            .map((json) => ItemKatalog.fromAniList(json, _selectedJenis))
            .toList();
        final existingIds = _items.map((e) => e.anilistId).toSet();
        final uniqueNewItems =
            newItems.where((e) => !existingIds.contains(e.anilistId)).toList();
        _items.addAll(uniqueNewItems);
        _hasNextPage = result.hasNextPage;
        _totalResults = result.total;
      }
    } catch (e) {
      if (gen == _requestGeneration) _handleLoadMoreError(e);
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

  ItemKatalog? getRandomItem() {
    if (_items.isEmpty) return null;
    final random = DateTime.now().millisecondsSinceEpoch % _items.length;
    return _items[random];
  }

  void _handleError(Object e) {
    if (e is RateLimitException) {
      _errorType = TipeError.rateLimit;
      _errorMessage =
          'Terlalu banyak permintaan ke server. Tunggu 30 detik lalu coba lagi.';
    } else if (e is NetworkException) {
      _errorType = TipeError.network;
      _errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    } else if (e is ApiException) {
      _errorType = TipeError.api;
      _errorMessage = 'Server sedang bermasalah. Coba lagi nanti.';
    } else {
      _errorType = TipeError.unknown;
      _errorMessage = 'Terjadi kesalahan tidak diketahui. Coba lagi.';
    }
  }

  void _handleLoadMoreError(Object e) {
    if (e is RateLimitException) {
      _loadMoreError =
          'Batas permintaan tercapai. Tunggu 30 detik lalu coba lagi.';
    } else if (e is NetworkException) {
      _loadMoreError = 'Koneksi terputus. Ketuk untuk coba lagi.';
    } else {
      _loadMoreError = 'Gagal memuat. Ketuk untuk coba lagi.';
    }
  }

  Future<bool> _loadPopularFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKeyPopular);
      if (raw == null || raw.isEmpty) return false;

      final obj = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.tryParse(obj['ts'] as String? ?? '');
      if (ts == null || DateTime.now().difference(ts) > _cacheTtl) return false;

      final animeJson = (obj['anime'] as List<dynamic>?) ?? [];
      final mangaJson = (obj['manga'] as List<dynamic>?) ?? [];
      final manhwaJson = (obj['manhwa'] as List<dynamic>?) ?? [];
      final manhuaJson = (obj['manhua'] as List<dynamic>?) ?? [];

      _popularAnime = animeJson.cast<Map<String, dynamic>>().map((j) => ItemKatalog.fromAniList(j, JenisMedia.anime)).toList();
      
      final cachedComics = <ItemKatalog>[
        ...mangaJson.cast<Map<String, dynamic>>().map((j) => ItemKatalog.fromAniList(j, JenisMedia.manga)),
        ...manhwaJson.cast<Map<String, dynamic>>().map((j) => ItemKatalog.fromAniList(j, JenisMedia.manhwa)),
        ...manhuaJson.cast<Map<String, dynamic>>().map((j) => ItemKatalog.fromAniList(j, JenisMedia.manhua)),
      ];
      
      cachedComics.sort((a, b) => (b.skor ?? 0).compareTo(a.skor ?? 0));
      _popularManga = cachedComics.take(10).toList();
      _hasFetchedPopular = _popularAnime.isNotEmpty || _popularManga.isNotEmpty;
      return _hasFetchedPopular;
    } catch (_) {
      return false;
    }
  }

  Future<void> _savePopularToCache(
    String cacheKey,
    List<Map<String, dynamic>> anime, 
    List<Map<String, dynamic>> manga,
    List<Map<String, dynamic>> manhwa,
    List<Map<String, dynamic>> manhua,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        cacheKey,
        jsonEncode({
          'ts': DateTime.now().toIso8601String(), 
          'anime': anime, 
          'manga': manga,
          'manhwa': manhwa,
          'manhua': manhua,
        }),
      );
    } catch (_) {}
  }

  Future<void> fetchPopularHome({bool forceRefresh = false}) async {
    if (forceRefresh) _hasFetchedPopular = false;

    if (!forceRefresh && !_hasFetchedPopular && _popularAnime.isEmpty && _popularManga.isEmpty) {
      final ok = await _loadPopularFromCache();
      if (ok) _safeNotify();
    }

    if (_isLoadingPopular && !forceRefresh) return;

    final gen = ++_popularGen;
    final cacheKey = _cacheKeyPopular;
    final nsfw = _isNsfwEnabled;
    
    _isLoadingPopular = true;
    _popularError = null;
    _safeNotify();

    try {
      int failCount = 0;
      final results = await Future.wait([
        _service.fetchPage(jenis: JenisMedia.anime, page: 1, isAdult: nsfw).catchError((_) { failCount++; return AniListResult(media: [], hasNextPage: false, total: 0); }),
        _service.fetchPage(jenis: JenisMedia.manga, page: 1, isAdult: nsfw).catchError((_) { failCount++; return AniListResult(media: [], hasNextPage: false, total: 0); }),
        _service.fetchPage(jenis: JenisMedia.manhwa, page: 1, isAdult: nsfw).catchError((_) { failCount++; return AniListResult(media: [], hasNextPage: false, total: 0); }),
        _service.fetchPage(jenis: JenisMedia.manhua, page: 1, isAdult: nsfw).catchError((_) { failCount++; return AniListResult(media: [], hasNextPage: false, total: 0); }),
      ]);

      if (gen != _popularGen) return;

      final newAnime = results[0].media;
      final mangaItems = results[1].media.map((json) => ItemKatalog.fromAniList(json, JenisMedia.manga)).toList();
      final manhwaItems = results[2].media.map((json) => ItemKatalog.fromAniList(json, JenisMedia.manhwa)).toList();
      final manhuaItems = results[3].media.map((json) => ItemKatalog.fromAniList(json, JenisMedia.manhua)).toList();

      if (newAnime.isNotEmpty) {
        _popularAnime = newAnime.map((json) => ItemKatalog.fromAniList(json, JenisMedia.anime)).toList();
      }
      
      final allComics = [...mangaItems, ...manhwaItems, ...manhuaItems];
      allComics.sort((a, b) => (b.skor ?? 0).compareTo(a.skor ?? 0));
      if (allComics.isNotEmpty) {
        _popularManga = allComics.take(10).toList();
      }

      if (_popularAnime.isEmpty && _popularManga.isEmpty) {
        _popularError = 'Gagal memuat data populer.';
      } else {
        _hasFetchedPopular = true;
        if (failCount == 0) {
          await _savePopularToCache(
            cacheKey,
            newAnime,
            results[1].media,
            results[2].media,
            results[3].media,
          );
        }
      }
    } catch (e) {
      _popularError = 'Gagal memuat data populer.';
    } finally {
      if (gen == _popularGen) {
        _isLoadingPopular = false;
        _safeNotify();
      }
    }
  }

  void setJenis(JenisMedia jenis) {
    if (_selectedJenis == jenis) return;
    _selectedJenis = jenis;
    fetchCatalog();
  }

  void toggleView() {
    _isListView = !_isListView;
    _safeNotify();
  }

  void setQuery(String query) {
    final trimmed = query.trim();
    if (_query == trimmed) return;
    _query = trimmed;
    if (_query.isEmpty && _urutan == UrutanKatalog.relevan) {
      _urutan = UrutanKatalog.populer;
    }
    fetchCatalog();
  }

  void setFilters({
    List<String>? genres,
    List<String>? tags,
    int? tahun,
    String? status,
    UrutanKatalog? urutan,
    int? skorMin,
  }) {
    bool changed = false;
    if (genres != null && !_listEquals(genres, _filterGenres)) { _filterGenres = List.from(genres); changed = true; }
    if (tags != null && !_listEquals(tags, _filterTags)) { _filterTags = List.from(tags); changed = true; }
    if (tahun != _filterTahun) { _filterTahun = tahun; changed = true; }
    if (status != _filterStatus) { _filterStatus = status; changed = true; }
    if (urutan != null && urutan != _urutan) { _urutan = urutan; changed = true; }
    if (skorMin != _filterSkorMin) { _filterSkorMin = skorMin; changed = true; }

    if (changed) fetchCatalog();
  }

  void clearFilters() {
    _filterGenres = [];
    _filterTags = [];
    _filterTahun = null;
    _filterStatus = null;
    _filterSkorMin = null;
    _urutan = UrutanKatalog.populer;
    fetchCatalog();
  }

  void clearAll() {
    _filterGenres = [];
    _filterTags = [];
    _filterTahun = null;
    _filterStatus = null;
    _filterSkorMin = null;
    _query = '';
    _urutan = UrutanKatalog.populer;
    fetchCatalog();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final setA = a.toSet();
    final setB = b.toSet();
    return setA.containsAll(setB) && setB.containsAll(setA);
  }
}