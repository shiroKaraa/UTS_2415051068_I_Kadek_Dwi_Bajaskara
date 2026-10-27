import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/collection_entry.dart';
import '../models/media_type_enum.dart';
import '../models/status_collection_enum.dart'; 
import '../repositories/collection_repository.dart';

enum UrutanKoleksi { terbaru, judul, progres, rating }

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository _repository;

  List<EntriKoleksi> _entries = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isOffline = false;
  String? _errorMessage;
  String? _deviceId;
  UrutanKoleksi _urutan = UrutanKoleksi.terbaru;
  StatusKoleksi? _filterStatus;
  bool _isListView = false;
  bool _filterFavorit = false;
  String _query = '';
  JenisMedia? _filterJenis;
  int? _filterRating;
  bool get isOffline => _isOffline;
  bool get isListView => _isListView;
  bool get filterFavorit => _filterFavorit;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UrutanKoleksi get urutan => _urutan;
  StatusKoleksi? get filterStatus => _filterStatus;
  String? get deviceId => _deviceId; 
  String get query => _query;
  JenisMedia? get filterJenis => _filterJenis;
  int? get filterRating => _filterRating;
  bool get hasActiveFilters =>
      _filterStatus != null || _filterJenis != null || _filterRating != null || _query.isNotEmpty || _filterFavorit;

  List<EntriKoleksi> get allEntries => _entries;

  List<EntriKoleksi> get entries {
    var filtered = List<EntriKoleksi>.from(_entries);
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      filtered = filtered.where((e) {
        final matchJudul = e.judul.toLowerCase().contains(q);
        final matchCatatan = e.catatan?.toLowerCase().contains(q) ?? false;
        return matchJudul || matchCatatan;
      }).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((e) => e.status == _filterStatus).toList();
    }

    if (_filterJenis != null) {
      filtered = filtered.where((e) => e.jenis == _filterJenis).toList();
    }

    if (_filterRating != null) {
      filtered = filtered.where((e) => e.rating == _filterRating).toList();
    }

    if (_filterFavorit) {
      filtered = filtered.where((e) => e.isFavorite).toList();
    }

    if (_urutan == UrutanKoleksi.terbaru) {
      filtered.sort((a, b) => (b.updatedAt ?? DateTime.now()).compareTo(a.updatedAt ?? DateTime.now()));
    } else if (_urutan == UrutanKoleksi.judul) {
      filtered.sort((a, b) => a.judul.toLowerCase().compareTo(b.judul.toLowerCase()));
    } else if (_urutan == UrutanKoleksi.progres) {
      filtered.sort((a, b) => b.progres.compareTo(a.progres));
    } else if (_urutan == UrutanKoleksi.rating) {
      filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    return filtered;
  }

  CollectionProvider(this._repository);

  void bindDevice(String? id) {
    if (_deviceId == id) return;
    _deviceId = id;
    _entries = [];
    _errorMessage = null;
    
    if (id != null) {
      Future.microtask(() => fetchCollection());
    } else {
      _errorMessage = 'ID Perangkat tidak tersedia. Tidak dapat memuat koleksi.';
      notifyListeners();
    }
  }

  Future<void> fetchCollection() async {
    if (_deviceId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getCollection(_deviceId!);
      _entries = data;
      _isOffline = false;
      
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.map((e) => e.toJson()).toList());
      await prefs.setString('cache_koleksi_$_deviceId', jsonString);

    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_koleksi_$_deviceId');
      
      if (cachedData != null && cachedData.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedData);
          _entries = decoded.map((json) => EntriKoleksi.fromJson(json)).toList();
          _isOffline = true; 
          _errorMessage = null;
        } catch (cacheError) {
          _entries = [];
          _errorMessage = 'Gagal membaca cache lokal.';
        }
      } else {
        _entries = [];
        _isOffline = false;
        _errorMessage = 'Gagal memuat koleksi. Periksa koneksi internet Anda.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEntry(EntriKoleksi entri) async {
    if (_deviceId == null || _isOffline) {
      _errorMessage = _isOffline ? 'Tidak dapat menambah data saat offline.' : 'ID Perangkat tidak valid.';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newEntry = await _repository.createEntry(entri);
      _entries.insert(0, newEntry);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateEntry(EntriKoleksi entri) async {
    if (_deviceId == null || _isOffline) {
      _errorMessage = _isOffline ? 'Tidak dapat mengubah data saat offline.' : 'ID Perangkat tidak valid.';
      notifyListeners();
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedEntry = await _repository.updateEntry(entri);
      final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEntry(EntriKoleksi entri) async {
    if (_deviceId == null || _isOffline) {
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
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> incrementProgress(EntriKoleksi entri) async {
    if (_isOffline) {
      _errorMessage = 'Tidak dapat menambah progres saat offline.';
      notifyListeners();
      return;
    }
    if (_isSaving) return;
    if (entri.status == StatusKoleksi.selesai) return;
    if (entri.total == null) return;
    if (entri.progres >= entri.total!) return;

    final newProgres = entri.progres + 1;
    final isSelesai = newProgres >= entri.total!;

    final updated = entri.copyWith(
      progres: newProgres,
      status: isSelesai ? StatusKoleksi.selesai : entri.status,
      updatedAt: DateTime.now(),
    );

    await updateEntry(updated);
  }

  Future<bool> toggleFavorite(EntriKoleksi entri) async {
    final updated = entri.copyWith(
      isFavorite: !entri.isFavorite,
      updatedAt: DateTime.now(),
    );
    return await updateEntry(updated);
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