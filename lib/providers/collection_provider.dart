import 'package:flutter/material.dart';
import '../models/collection_entry.dart';
import '../repositories/collection_repository.dart';
import '../providers/settings_provider.dart';

class CollectionProvider extends ChangeNotifier {
  final CollectionRepository _repository;
  final SettingsProvider _settingsProvider;

  List<EntriKoleksi> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EntriKoleksi> get entries => _entries;
  bool get isLoading => _isLoading;
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
      _entries = await _repository.getCollection(_settingsProvider.deviceId);
    } catch (e) {
      _errorMessage = e.toString();
      _entries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchCollection();
  }
}