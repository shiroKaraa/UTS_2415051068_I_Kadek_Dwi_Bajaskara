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

enum UrutanKoleksi { terbaru, ditambahkan, judul, progres, rating }
enum HasilIncrement { ok, offline, alreadyCompleted, error, inFlight }

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository _repository;

  List<EntriKoleksi> _entries = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isOffline = false;
  String? _errorMessage;
  String? _userId;
  int _fetchGen = 0;
  bool _disposed = false;
  final Set<int> _inFlight = {};

  UrutanKoleksi _urutan = UrutanKoleksi.terbaru;
  bool _urutanAsc = false;
  StatusKoleksi? _filterStatus;
  bool _isListView = false;
  bool _filterFavorit = false;
  String _query = '';
  JenisMedia? _filterJenis;
  int? _filterRating;

  ProfileStats? _cachedStats;
  List<EntriKoleksi>? _filteredCache;
  List<EntriKoleksi>? _continueCache;
  Map<String, EntriKoleksi>? _externalIndex;
  Timer? _cacheTimer;
  Timer? _reconnectTimer;

  bool get isOffline => _isOffline;
  bool get isListView => _isListView;
  bool get filterFavorit => _filterFavorit;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UrutanKoleksi get urutan => _urutan;
  bool get urutanAsc => _urutanAsc;
  StatusKoleksi? get filterStatus => _filterStatus;
  String? get userId => _userId;
  String get query => _query;
  JenisMedia? get filterJenis => _filterJenis;
  int? get filterRating => _filterRating;

  bool get hasActiveFilters =>
      _filterStatus != null ||
      _filterJenis != null ||
      _filterRating != null ||
      _query.isNotEmpty ||
      _filterFavorit;

  UnmodifiableListView<EntriKoleksi> get allEntries =>
      UnmodifiableListView(_entries);

  ProfileStats get stats {
    _cachedStats ??= ProfileStats.fromEntries(_entries);
    return _cachedStats!;
  }

  List<EntriKoleksi> get continueWatching {
    if (_continueCache != null) return _continueCache!;
    final list = _entries
        .where((e) => e.status == StatusKoleksi.sedang)
        .toList(growable: false);
    final fallback = DateTime.fromMillisecondsSinceEpoch(0);
    list.sort((a, b) =>
        (b.updatedAt ?? fallback).compareTo(a.updatedAt ?? fallback));
    _continueCache = list.take(3).toList(growable: false);
    return _continueCache!;
  }

  List<EntriKoleksi> get entries {
    if (_filteredCache != null) return _filteredCache!;

    final q = _query.toLowerCase();
    final hasQuery = q.isNotEmpty;

    final filtered = <EntriKoleksi>[];
    for (final e in _entries) {
      if (hasQuery) {
        final matchJudul = e.judul.toLowerCase().contains(q);
        final matchCatatan = e.catatan?.toLowerCase().contains(q) ?? false;
        if (!matchJudul && !matchCatatan) continue;
      }
      if (_filterStatus != null && e.status != _filterStatus) continue;
      if (_filterJenis != null && e.jenis != _filterJenis) continue;
      if (_filterRating != null) {
        if ((e.rating ?? 0) < _filterRating!) continue;
      }
      if (_filterFavorit && !e.isFavorite) continue;
      filtered.add(e);
    }

    final cmp = _getComparator();
    if (_urutanAsc) {
      filtered.sort(cmp);
    } else {
      filtered.sort((a, b) => cmp(b, a));
    }

    _filteredCache = filtered;
    return _filteredCache!;
  }

  int Function(EntriKoleksi, EntriKoleksi) _getComparator() {
    final fallback = DateTime.fromMillisecondsSinceEpoch(0);
    switch (_urutan) {
      case UrutanKoleksi.terbaru:
        return (a, b) =>
            (a.updatedAt ?? fallback).compareTo(b.updatedAt ?? fallback);
      case UrutanKoleksi.ditambahkan:
        return (a, b) =>
            (a.createdAt ?? fallback).compareTo(b.createdAt ?? fallback);
      case UrutanKoleksi.judul:
        return (a, b) =>
            a.judul.toLowerCase().compareTo(b.judul.toLowerCase());
      case UrutanKoleksi.progres:
        return (a, b) => a.progres.compareTo(b.progres);
      case UrutanKoleksi.rating:
        return (a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0);
    }
  }

  CollectionProvider(this._repository);

  @override
  void dispose() {
    _disposed = true;
    _cacheTimer?.cancel();
    _reconnectTimer?.cancel();
    _inFlight.clear();
    super.dispose();
  }

  void _notifyDataChanged() {
    _cachedStats = null;
    _filteredCache = null;
    _continueCache = null;
    _externalIndex = null;
    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  bool _isNetworkError(Object e) {
    if (e is TimeoutException) return true;
    final s = e.toString();
    return s.contains('SocketException') ||
        s.contains('ClientException') ||
        s.contains('HandshakeException') ||
        s.contains('Failed host lookup') ||
        s.contains('AuthRetryableFetchException');
  }

  String _friendlyError(Object e) {
    if (e is TimeoutException) {
      return 'Server terlalu lama merespons. Coba lagi.';
    }
    if (_isNetworkError(e)) {
      return 'Koneksi terputus. Periksa internet Anda.';
    }
    final raw = e.toString().replaceAll('Exception: ', '').trim();
    if (raw.isEmpty) return 'Terjadi kesalahan. Coba lagi.';
    if (raw.length > 200) return 'Terjadi kesalahan pada server. Coba lagi.';
    return raw;
  }

  EntriKoleksi _reconcileStatus(EntriKoleksi entri) {
    if (entri.total == null) return entri;

    final isFull = entri.progres >= entri.total!;

    if (isFull && entri.status != StatusKoleksi.selesai) {
      return entri.copyWith(status: StatusKoleksi.selesai);
    } else if (!isFull && entri.status == StatusKoleksi.selesai) {
      return entri.copyWith(status: StatusKoleksi.sedang);
    } else if (entri.progres > 0 &&
        entri.status == StatusKoleksi.direncanakan) {
      return entri.copyWith(status: StatusKoleksi.sedang);
    }
    return entri;
  }

  Future<T> _runSaving<T>(
    Future<T> Function() action, {
    required T onError,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    _safeNotify();
    try {
      return await action();
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return onError;
    } finally {
      _isSaving = false;
      _safeNotify();
    }
  }

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _fetchGen++;
    _cacheTimer?.cancel();
    _reconnectTimer?.cancel();
    _userId = userId;
    _entries = [];
    _inFlight.clear();
    _errorMessage = null;
    _isOffline = false;
    _isLoading = false;
    _isSaving = false;
    _cachedStats = null;
    _filteredCache = null;
    _continueCache = null;
    _externalIndex = null;

    if (userId != null) {
      Future.microtask(() => fetchCollection());
    } else {
      Future.microtask(() => _safeNotify());
    }
  }

  String _cacheKeyFor(String userId) => 'cache_koleksi_$userId';

  void _scheduleSaveCache() {
    if (_userId == null) return;
    _cacheTimer?.cancel();
    _cacheTimer = Timer(const Duration(seconds: 1), _saveCache);
  }

  Future<void> _saveCache() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString =
          jsonEncode(_entries.map((e) => e.toCacheJson()).toList());
      await prefs.setString(_cacheKeyFor(_userId!), jsonString);
    } catch (_) {}
  }

  Future<void> fetchCollection() async {
    final userId = _userId;
    if (userId == null) return;

    final gen = ++_fetchGen;
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final data = await _repository.getCollection(userId);
      if (gen != _fetchGen || _userId != userId) return;

      _entries = data;
      _isOffline = false;
      _reconnectTimer?.cancel();
      _scheduleSaveCache();
      _notifyDataChanged();
    } catch (e) {
      if (gen != _fetchGen || _userId != userId) return;

      if (_isNetworkError(e)) {
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(_cacheKeyFor(userId));
        if (cachedData != null && cachedData.isNotEmpty) {
          try {
            final List<dynamic> decoded = jsonDecode(cachedData);
            _entries = decoded
                .map((json) => EntriKoleksi.fromJson(json))
                .toList();
            _isOffline = true;
            _errorMessage = null;
            _scheduleReconnectCheck();
          } catch (_) {
            _entries = [];
            _isOffline = true;
            _errorMessage = 'Gagal membaca cache lokal.';
            _scheduleReconnectCheck();
          }
        } else {
          if (_entries.isEmpty) {
            _isOffline = false;
            _errorMessage =
                'Gagal memuat koleksi. Periksa koneksi internet Anda.';
          } else {
            _isOffline = true;
            _scheduleReconnectCheck();
          }
        }
      } else {
        _isOffline = false;
        _errorMessage =
            'Terjadi kesalahan sistem: ${e.toString().replaceAll('Exception: ', '')}';
      }
      _notifyDataChanged();
    } finally {
      if (gen == _fetchGen) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  Future<bool> retryConnection() async {
    if (!_isOffline) return true;
    try {
      final ok = await _repository.pingServer();
      if (!ok) return false;
      _isOffline = false;
      _reconnectTimer?.cancel();
      _safeNotify();
      await fetchCollection();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _scheduleReconnectCheck() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 30), () async {
      if (!_isOffline) return;
      final ok = await retryConnection();
      if (!ok && _isOffline) _scheduleReconnectCheck();
    });
  }

  Map<String, EntriKoleksi> get _extIndex {
    _externalIndex ??= {
      for (var e in _entries)
        if (e.externalId != null) '${e.jenis.name}:${e.externalId}': e
    };
    return _externalIndex!;
  }

  EntriKoleksi? findById(int id) => _entries
      .cast<EntriKoleksi?>()
      .firstWhere((e) => e?.id == id, orElse: () => null);

  EntriKoleksi? findByExternal(String externalId, JenisMedia jenis) =>
      _extIndex['${jenis.name}:$externalId'];

  bool hasDuplicateTitle(String judul, JenisMedia jenis) {
    final key = judul.trim().toLowerCase();
    return _entries.any((e) =>
        e.externalId == null &&
        e.jenis == jenis &&
        e.judul.trim().toLowerCase() == key);
  }

  Future<bool> createEntry(EntriKoleksi entri) async {
    if (_userId == null) {
      _errorMessage = 'Silakan login terlebih dahulu.';
      _safeNotify();
      return false;
    }

    if (entri.externalId != null) {
      final existing = findByExternal(entri.externalId!, entri.jenis);
      if (existing != null) {
        _errorMessage = 'Anime/komik ini sudah ada di koleksimu.';
        _safeNotify();
        return false;
      }
    }

    if (_isOffline) {
      final isOnline = await _repository.pingServer();
      if (!isOnline) {
        _errorMessage = 'Tidak dapat menambah data saat offline.';
        _safeNotify();
        return false;
      }
      _isOffline = false;
      _reconnectTimer?.cancel();
    }

    _isSaving = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final toInsert =
          entri.id != null ? entri.copyWith(clearId: true) : entri;
      final newEntry = await _repository.createEntry(toInsert);
      _entries.insert(0, newEntry);
      _scheduleSaveCache();
      _notifyDataChanged();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _isSaving = false;
      _safeNotify();
    }
  }

  Future<int> createEntries(List<EntriKoleksi> entries) async {
    if (_userId == null || _isOffline || entries.isEmpty) return 0;
    _isSaving = true;
    _errorMessage = null;
    _safeNotify();

    try {
      final newEntries = await _repository.createEntries(entries);
      _entries.insertAll(0, newEntries);
      _scheduleSaveCache();
      _notifyDataChanged();
      return newEntries.length;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return 0;
    } finally {
      _isSaving = false;
      _safeNotify();
    }
  }

  Future<bool> updateEntry(EntriKoleksi entri) async {
    if (_userId == null || _isOffline) {
      _errorMessage = _isOffline
          ? 'Tidak dapat mengubah data saat offline.'
          : 'ID Perangkat tidak valid.';
      _safeNotify();
      return false;
    }
    return _runSaving(() async {
      final updated = await _repository.updateEntry(entri);
      final index = _entries.indexWhere((e) => e.id == updated.id);
      if (index != -1) _entries[index] = updated;
      _scheduleSaveCache();
      _notifyDataChanged();
      return true;
    }, onError: false);
  }

  Future<bool> deleteEntry(EntriKoleksi entri) async {
    if (_userId == null || _isOffline) {
      _errorMessage = _isOffline
          ? 'Tidak dapat menghapus data saat offline.'
          : 'ID tidak valid.';
      _safeNotify();
      return false;
    }
    final id = entri.id;
    if (id == null) return false;

    return _runSaving(() async {
      await _repository.deleteEntry(id);
      _entries.removeWhere((e) => e.id == id);
      _scheduleSaveCache();
      _notifyDataChanged();
      return true;
    }, onError: false);
  }

  Future<int> deleteAll() async {
    if (_userId == null || _isOffline) {
      _errorMessage = _isOffline
          ? 'Tidak dapat menghapus saat offline.'
          : 'ID Perangkat tidak valid.';
      _safeNotify();
      return 0;
    }

    return _runSaving(() async {
      final count = _entries.length;
      await _repository.deleteAll(_userId!);
      _entries.clear();
      _scheduleSaveCache();
      _notifyDataChanged();
      return count;
    }, onError: 0);
  }

  Future<int> deleteMany(Set<int> ids) async {
    if (_userId == null || _isOffline || ids.isEmpty) {
      _errorMessage = _isOffline
          ? 'Tidak dapat menghapus data saat offline.'
          : 'Tidak ada item yang dipilih.';
      _safeNotify();
      return 0;
    }
    return _runSaving(() async {
      final idList = ids.toList(growable: false);
      await _repository.deleteEntries(idList);
      _entries.removeWhere((e) => ids.contains(e.id));
      _scheduleSaveCache();
      _notifyDataChanged();
      return idList.length;
    }, onError: 0);
  }

  Future<int> updateManyStatus(Set<int> ids, StatusKoleksi status) async {
    if (_userId == null || _isOffline || ids.isEmpty) {
      _errorMessage = _isOffline
          ? 'Tidak dapat mengubah data saat offline.'
          : 'Tidak ada item yang dipilih.';
      _safeNotify();
      return 0;
    }
    return _runSaving(() async {
      final idList = ids.toList(growable: false);
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      await _repository.updateEntriesFields(idList, {
        'status': status.name,
        'updated_at': nowUtc,
      });
      final now = DateTime.now();
      for (int i = 0; i < _entries.length; i++) {
        final e = _entries[i];
        if (!ids.contains(e.id)) continue;
        _entries[i] = e.copyWith(status: status, updatedAt: now);
      }
      _scheduleSaveCache();
      _notifyDataChanged();
      return idList.length;
    }, onError: 0);
  }

  Future<int> updateManyLabel(Set<int> ids, int? labelId) async {
    if (_userId == null || _isOffline || ids.isEmpty) {
      _errorMessage = _isOffline
          ? 'Tidak dapat mengubah data saat offline.'
          : 'Tidak ada item yang dipilih.';
      _safeNotify();
      return 0;
    }
    return _runSaving(() async {
      final idList = ids.toList(growable: false);
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      await _repository.updateEntriesFields(idList, {
        'label_id': labelId,
        'updated_at': nowUtc,
      });
      final now = DateTime.now();
      for (int i = 0; i < _entries.length; i++) {
        final e = _entries[i];
        if (!ids.contains(e.id)) continue;
        _entries[i] = e.copyWith(
          labelId: labelId,
          clearLabelId: labelId == null,
          updatedAt: now,
        );
      }
      _scheduleSaveCache();
      _notifyDataChanged();
      return idList.length;
    }, onError: 0);
  }

  Future<HasilIncrement> incrementProgress(EntriKoleksi entri) async {
    final id = entri.id;
    if (id == null) {
      _errorMessage = 'Entri tidak valid.';
      _safeNotify();
      return HasilIncrement.error;
    }
    if (_isOffline) return HasilIncrement.offline;
    if (entri.status == StatusKoleksi.selesai) {
      return HasilIncrement.alreadyCompleted;
    }
    if (!_inFlight.add(id)) return HasilIncrement.inFlight;
    try {
      final current = findById(id);
      if (current == null) {
        _errorMessage = 'Entri tidak ditemukan. Coba refresh koleksi.';
        _safeNotify();
        return HasilIncrement.error;
      }

      if (current.total != null && current.progres >= current.total!) {
        return HasilIncrement.alreadyCompleted;
      }

      final index = _entries.indexWhere((e) => e.id == id);
      if (index == -1) {
        _errorMessage = 'Entri tidak ditemukan. Coba refresh koleksi.';
        _safeNotify();
        return HasilIncrement.error;
      }

      final old = _entries[index];
      final newProgres = current.progres + 1;
      final isSelesai =
          current.total != null && newProgres >= current.total!;

      StatusKoleksi newStatus = current.status;
      if (isSelesai) {
        newStatus = StatusKoleksi.selesai;
      } else if (current.status == StatusKoleksi.direncanakan) {
        newStatus = StatusKoleksi.sedang;
      }

      final updated = _reconcileStatus(current.copyWith(
        progres: newProgres,
        status: newStatus,
        updatedAt: DateTime.now(),
      ));

      _entries[index] = updated;
      _notifyDataChanged();

      try {
        final saved = await _repository.updateEntry(updated);
        final i = _entries.indexWhere((e) => e.id == saved.id);
        if (i != -1) _entries[i] = saved;
        _scheduleSaveCache();
        _notifyDataChanged();
        return HasilIncrement.ok;
      } catch (e) {
        final i = _entries
            .indexWhere((e) => e.id == old.id && e.progres == newProgres);
        if (i != -1) _entries[i] = old;
        _errorMessage = _friendlyError(e);
        _notifyDataChanged();
        return HasilIncrement.error;
      }
    } finally {
      _inFlight.remove(id);
    }
  }

  Future<bool> decrementProgress(EntriKoleksi entri) async {
    if (_isOffline || _isSaving) return false;
    if (entri.progres <= 0) return false;

    final newProgres = entri.progres - 1;

    StatusKoleksi newStatus = entri.status;
    if (newProgres == 0) {
      newStatus = StatusKoleksi.direncanakan;
    } else if (entri.status == StatusKoleksi.selesai &&
        (entri.total == null || newProgres < entri.total!)) {
      newStatus = StatusKoleksi.sedang;
    }

    final updated = _reconcileStatus(entri.copyWith(
      progres: newProgres,
      status: newStatus,
      updatedAt: DateTime.now(),
    ));
    return updateEntry(updated);
  }

  Future<bool> toggleFavorite(EntriKoleksi entri) async {
    final updated = entri.copyWith(isFavorite: !entri.isFavorite);
    return updateEntryPreserveUpdatedAt(updated, entri.updatedAt);
  }

  void clearLabelFromEntries(int labelId) {
    bool changed = false;
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].labelId == labelId) {
        _entries[i] = _entries[i].copyWith(clearLabelId: true);
        changed = true;
      }
    }
    if (changed) {
      _scheduleSaveCache();
      _notifyDataChanged();
    }
  }

  Future<bool> updateEntryPreserveUpdatedAt(
    EntriKoleksi entri,
    DateTime? preserveUpdatedAt,
  ) async {
    if (_userId == null || _isOffline) {
      _errorMessage = _isOffline
          ? 'Tidak dapat mengubah data saat offline.'
          : 'ID Perangkat tidak valid.';
      _safeNotify();
      return false;
    }
    return _runSaving(() async {
      final updated = await _repository.updateEntry(entri);
      final index = _entries.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _entries[index] =
            updated.updatedAt == null && preserveUpdatedAt != null
                ? updated.copyWith(updatedAt: preserveUpdatedAt)
                : updated;
      }
      _scheduleSaveCache();
      _notifyDataChanged();
      return true;
    }, onError: false);
  }

  Future<int> countClaimableCollections(String deviceId) async {
    try {
      return await _repository.countClaimableCollections(deviceId);
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
    _notifyDataChanged();
  }

  void setUrutan(UrutanKoleksi urutan) {
    if (_urutan == urutan) return;
    _urutan = urutan;
    switch (urutan) {
      case UrutanKoleksi.judul:
        _urutanAsc = true;
        break;
      case UrutanKoleksi.terbaru:
      case UrutanKoleksi.ditambahkan:
      case UrutanKoleksi.progres:
      case UrutanKoleksi.rating:
        _urutanAsc = false;
        break;
    }
    _notifyDataChanged();
  }

  void setUrutanDirection(bool ascending) {
    if (_urutanAsc == ascending) return;
    _urutanAsc = ascending;
    _notifyDataChanged();
  }

  void setFilterStatus(StatusKoleksi? status) {
    if (_filterStatus == status) return;
    _filterStatus = status;
    _notifyDataChanged();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    _notifyDataChanged();
  }

  void setFilters({JenisMedia? jenis, int? rating, StatusKoleksi? status}) {
    _filterJenis = jenis;
    _filterRating = rating;
    _filterStatus = status;
    _notifyDataChanged();
  }

  void clearFilters() {
    _filterJenis = null;
    _filterRating = null;
    _filterStatus = null;
    _query = '';
    _filterFavorit = false;
    _notifyDataChanged();
  }

  void toggleView() {
    _isListView = !_isListView;
    _safeNotify();
  }

  Future<void> refresh() async {
    await fetchCollection();
  }
}