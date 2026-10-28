import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_entry.dart';
import '../models/media_type_enum.dart';
import '../models/status_collection_enum.dart';
import '../models/profile_stats.dart';
import '../repositories/collection_repository.dart';

enum UrutanKoleksi { terbaru, judul, progres, rating }
enum HasilIncrement { ok, offline, alreadyCompleted, error }

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository _repository;

  List<EntriKoleksi> _entries = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isOffline = false;
  String? _errorMessage;
  String? _userId;
  int _fetchGen = 0;
  
  UrutanKoleksi _urutan = UrutanKoleksi.terbaru;
  StatusKoleksi? _filterStatus;
  bool _isListView = false;
  bool _filterFavorit = false;
  String _query = '';
  JenisMedia? _filterJenis;
  int? _filterRating;
  
  ProfileStats? _cachedStats;
  List<EntriKoleksi>? _filteredCache;
  Map<String, EntriKoleksi>? _externalIndex;

  bool get isOffline => _isOffline;
  bool get isListView => _isListView;
  bool get filterFavorit => _filterFavorit;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UrutanKoleksi get urutan => _urutan;
  StatusKoleksi? get filterStatus => _filterStatus;
  String? get userId => _userId;
  String get query => _query;
  JenisMedia? get filterJenis => _filterJenis;
  int? get filterRating => _filterRating;
  
  bool get hasActiveFilters =>
      _filterStatus != null || _filterJenis != null || _filterRating != null || _query.isNotEmpty || _filterFavorit;

  UnmodifiableListView<EntriKoleksi> get allEntries => UnmodifiableListView(_entries);

  ProfileStats get stats {
    _cachedStats ??= ProfileStats.fromEntries(_entries);
    return _cachedStats!;
  }

  List<EntriKoleksi> get continueWatching {
    final list = _entries.where((e) => e.status == StatusKoleksi.sedang).toList();
    final fallback = DateTime.fromMillisecondsSinceEpoch(0);
    list.sort((a, b) => (b.updatedAt ?? fallback).compareTo(a.updatedAt ?? fallback));
    return list.take(3).toList();
  }

  List<EntriKoleksi> get entries {
    if (_filteredCache != null) return _filteredCache!;
    
    var filtered = List<EntriKoleksi>.from(_entries);
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = filtered.where((e) {
        final matchJudul = e.judul.toLowerCase().contains(q);
        final matchCatatan = e.catatan?.toLowerCase().contains(q) ?? false;
        return matchJudul || matchCatatan;
      }).toList();
    }
    if (_filterStatus != null) filtered = filtered.where((e) => e.status == _filterStatus).toList();
    if (_filterJenis != null) filtered = filtered.where((e) => e.jenis == _filterJenis).toList();
    if (_filterRating != null) filtered = filtered.where((e) => e.rating == _filterRating).toList();
    if (_filterFavorit) filtered = filtered.where((e) => e.isFavorite).toList();

    final fallback = DateTime.fromMillisecondsSinceEpoch(0);
    if (_urutan == UrutanKoleksi.terbaru) {
      filtered.sort((a, b) => (b.updatedAt ?? fallback).compareTo(a.updatedAt ?? fallback));
    } else if (_urutan == UrutanKoleksi.judul) {
      filtered.sort((a, b) => a.judul.toLowerCase().compareTo(b.judul.toLowerCase()));
    } else if (_urutan == UrutanKoleksi.progres) {
      filtered.sort((a, b) => b.progres.compareTo(a.progres));
    } else if (_urutan == UrutanKoleksi.rating) {
      filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }
    
    _filteredCache = filtered;
    return _filteredCache!;
  }

  CollectionProvider(this._repository);

  @override
  void notifyListeners() {
    _cachedStats = null;
    _filteredCache = null;
    super.notifyListeners();
  }

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _entries = [];
    _errorMessage = null;
    _isOffline = false;
    _isLoading = false;
    _isSaving = false;
    _externalIndex = null;

    if (userId != null) {
      fetchCollection();
    } else {
      notifyListeners();
    }
  }

  String _cacheKeyFor(String userId) => 'cache_koleksi_$userId';

  Future<void> _saveCache() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_entries.map((e) => e.toCacheJson()).toList());
    await prefs.setString(_cacheKeyFor(_userId!), jsonString);
  }

  Future<void> fetchCollection() async {
    final userId = _userId;
    if (userId == null) return;
    
    final gen = ++_fetchGen;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getCollection(userId);
      if (gen != _fetchGen) return;

      _entries = data;
      _isOffline = false;
      await _saveCache();
    } catch (e) {
      if (gen != _fetchGen) return;

      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKeyFor(userId));
      if (cachedData != null && cachedData.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData);
          _entries = decoded.map((json) => EntriKoleksi.fromJson(json)).toList();
          _isOffline = true;
          _errorMessage = null;
        } catch (_) {
          _entries = [];
          _errorMessage = 'Gagal membaca cache lokal.';
        }
      } else {
        _entries = [];
        _isOffline = false;
        _errorMessage = 'Gagal memuat koleksi. Periksa koneksi internet Anda.';
      }
    } finally {
      if (gen == _fetchGen) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Map<String, EntriKoleksi> get _extIndex {
    _externalIndex ??= {
      for (var e in _entries) 
        if (e.externalId != null) '${e.jenis.name}:${e.externalId}': e
    };
    return _externalIndex!;
  }

  EntriKoleksi? findById(int id) => _entries.cast<EntriKoleksi?>().firstWhere((e) => e?.id == id, orElse: () => null);
  EntriKoleksi? findByExternal(String externalId, JenisMedia jenis) => _extIndex['${jenis.name}:$externalId'];

  Future<bool> createEntry(EntriKoleksi entri) async {
    if (_userId == null) {
      _errorMessage = 'Silakan login terlebih dahulu.';
      notifyListeners();
      return false;
    }
    
    if (entri.externalId != null) {
      final existing = findByExternal(entri.externalId!, entri.jenis);
      if (existing != null) {
        _errorMessage = 'Anime/komik ini sudah ada di koleksimu.';
        notifyListeners();
        return false;
      }
    }

    if (_isOffline) {
      try {
        await _repository.getCollection(_userId!);
        _isOffline = false;
      } catch (_) {
        _errorMessage = 'Tidak dapat menambah data saat offline.';
        notifyListeners();
        return false;
      }
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newEntry = await _repository.createEntry(entri);
      _entries.insert(0, newEntry);
      _externalIndex = null;
      await _saveCache();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<int> createEntries(List<EntriKoleksi> entries) async {
    if (_userId == null || _isOffline || entries.isEmpty) return 0;
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newEntries = await _repository.createEntries(entries);
      _entries.insertAll(0, newEntries);
      _externalIndex = null;
      await _saveCache();
      return newEntries.length;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return 0;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateEntry(EntriKoleksi entri) async {
    if (_userId == null || _isOffline) {
      _errorMessage = _isOffline ? 'Tidak dapat mengubah data saat offline.' : 'ID Perangkat tidak valid.';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateEntry(entri);
      final index = _entries.indexWhere((e) => e.id == updated.id);
      if (index != -1) _entries[index] = updated;
      _externalIndex = null;
      await _saveCache();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEntry(EntriKoleksi entri) async {
    if (_userId == null || _isOffline) {
      _errorMessage = _isOffline ? 'Tidak dapat menghapus data saat offline.' : 'ID Perangkat tidak valid.';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteEntry(entri.id!);
      _entries.removeWhere((e) => e.id == entri.id);
      _externalIndex = null;
      await _saveCache();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<int> deleteAll() async {
    if (_userId == null || _isOffline) {
      _errorMessage = _isOffline ? 'Tidak dapat menghapus saat offline.' : 'ID Perangkat tidak valid.';
      notifyListeners();
      return 0;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final count = _entries.length;
      await _repository.deleteAll(_userId!);
      _entries.clear();
      _externalIndex = null;
      await _saveCache();
      return count;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return 0;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<HasilIncrement> incrementProgress(EntriKoleksi entri) async {
    if (_isOffline) return HasilIncrement.offline;
    if (_isSaving) return HasilIncrement.error;
    if (entri.status == StatusKoleksi.selesai) return HasilIncrement.alreadyCompleted;
    if (entri.total != null && entri.progres >= entri.total!) return HasilIncrement.alreadyCompleted;

    final newProgres = entri.progres + 1;
    final isSelesai = entri.total != null && newProgres >= entri.total!;
    
    StatusKoleksi newStatus = entri.status;
    if (isSelesai) {
      newStatus = StatusKoleksi.selesai;
    } else if (entri.status == StatusKoleksi.direncanakan) {
      newStatus = StatusKoleksi.sedang;
    }

    final updated = entri.copyWith(
      progres: newProgres,
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    
    final success = await updateEntry(updated);
    return success ? HasilIncrement.ok : HasilIncrement.error;
  }

  Future<bool> decrementProgress(EntriKoleksi entri) async {
    if (_isOffline || _isSaving) return false;
    if (entri.progres <= 0) return false;

    final newProgres = entri.progres - 1;
    final updated = entri.copyWith(
      progres: newProgres,
      status: newProgres == 0 ? StatusKoleksi.direncanakan : entri.status,
      updatedAt: DateTime.now(),
    );
    return updateEntry(updated);
  }

  Future<bool> toggleFavorite(EntriKoleksi entri) async {
    final updated = entri.copyWith(
      isFavorite: !entri.isFavorite,
      updatedAt: DateTime.now(),
    );
    return updateEntry(updated);
  }

  Future<int> countClaimableCollections(String deviceId) async {
    try {
      final res = await _repository.getCollection(_userId!);
      return res.length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> claimDeviceCollections(String deviceId) async {
    final userIdAtStart = _userId;
    if (userIdAtStart == null) return 0;
    
    try {
      final res = await Supabase.instance.client.rpc(
        'claim_device_collections',
        params: {'p_device_id': deviceId},
      );
      final claimed = res is int ? res : 0;
      
      if (claimed > 0 && _userId == userIdAtStart) {
        await fetchCollection();
      }
      return claimed;
    } catch (e) {
      debugPrint('Error claim: $e');
      return 0;
    }
  }

  void setFilterFavorit(bool value) {
    if (_filterFavorit == value) return;
    _filterFavorit = value;
    notifyListeners();
  }

  void setUrutan(UrutanKoleksi urutan) {
    if (_urutan == urutan) return;
    _urutan = urutan;
    notifyListeners();
  }

  void setFilterStatus(StatusKoleksi? status) {
    if (_filterStatus == status) return;
    _filterStatus = status;
    notifyListeners();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    notifyListeners();
  }

  void setFilters({JenisMedia? jenis, int? rating, StatusKoleksi? status}) {
    _filterJenis = jenis;
    _filterRating = rating;
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _filterJenis = null;
    _filterRating = null;
    _filterStatus = null;
    _query = '';
    _filterFavorit = false;
    notifyListeners();
  }

  void toggleView() {
    _isListView = !_isListView;
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchCollection();
  }
}