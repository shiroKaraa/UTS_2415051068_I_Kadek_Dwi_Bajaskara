import 'package:flutter/material.dart';
import '../models/collection_entry.dart';
import '../repositories/collection_repository.dart';
import '../models/status_collection_enum.dart';
import '../providers/settings_provider.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository _repository;
  final SettingsProvider _settingsProvider;

  List<EntriKoleksi> _entries = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<EntriKoleksi> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  CollectionProvider(this._repository, this._settingsProvider) {
    fetchCollection();
  }

  Future<void> fetchCollection() async {
    if (_settingsProvider.deviceId == 'Memuat ID...') {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getCollection(_settingsProvider.deviceId);
      data.sort((a, b) => (b.updatedAt ?? DateTime.now()).compareTo(a.updatedAt ?? DateTime.now()));
      _entries = data;
    } catch (e) {
      _errorMessage = 'Gagal memuat koleksi. Periksa koneksi internet Anda.';
      _entries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEntry(EntriKoleksi entri) async {
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
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedEntry = await _repository.updateEntry(entri);
      final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        _entries.sort((a, b) => (b.updatedAt ?? DateTime.now()).compareTo(a.updatedAt ?? DateTime.now()));
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

  Future<void> incrementProgress(EntriKoleksi entri) async {
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

  Future<bool> deleteEntry(EntriKoleksi entri) async {
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

  Future<void> refresh() async {
    await fetchCollection();
  }
}