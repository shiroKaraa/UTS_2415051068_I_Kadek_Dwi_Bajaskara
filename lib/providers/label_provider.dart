import 'package:flutter/material.dart';
import '../../models/custom_label.dart';
import '../services/label_service.dart';

class LabelProvider extends ChangeNotifier {
  final LabelService _service = LabelService();
  List<LabelKustom> _labels = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _userId;

  List<LabelKustom> get labels => _labels;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  String? get userId => _userId;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _labels = [];
    _hasLoaded = false;
    _errorMessage = null;

    if (userId != null) {
      Future.microtask(() => fetchLabels());
    } else {
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> fetchLabels() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _labels = await _service.getLabels(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat label: $e';
    } finally {
      _isLoading = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> createLabel(String nama, {String warna = '#5FCB97'}) async {
    final userId = _userId;
    if (userId == null) return false;
    try {
      final newLabel = await _service.createLabel(
        LabelKustom(
          userId: userId,
          nama: nama,
          warna: warna,
        ),
      );
      _labels.add(newLabel);
      _labels.sort(
        (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah label: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLabel(LabelKustom label) async {
    try {
      final updated = await _service.updateLabel(label);
      final index = _labels.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _labels[index] = updated;
        _labels.sort(
          (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengedit label: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLabel(LabelKustom label) async {
    final id = label.id;
    if (id == null) return false;

    try {
      await _service.deleteLabel(id, label.userId);
      _labels.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus label: $e';
      notifyListeners();
      return false;
    }
  }

  LabelKustom? findById(int? id) {
    if (id == null) return null;
    for (final c in _labels) {
      if (c.id == id) return c;
    }
    return null;
  }
}