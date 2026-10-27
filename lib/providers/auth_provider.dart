import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService() {
    _init();
  }

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _username;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<AuthState>? _sub;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get username => _username;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _user?.id;

  void _init() {
    _sub = _service.onAuthStateChange.listen((state) async {
      final user = state.session?.user;
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _loadProfile();
        if (_user?.id == user.id) {
          notifyListeners();
        }
      } else {
        _user = null;
        _username = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });

    final current = _service.currentUser;
    if (current != null) {
      _user = current;
      _status = AuthStatus.authenticated;
      _loadProfile().then((_) {
        if (_user?.id == current.id) notifyListeners();
      });
    } else {
      _status = AuthStatus.unauthenticated;
      Future.microtask(notifyListeners);
    }
  }

  Future<void> _loadProfile() async {
    final userIdAtStart = _user?.id;
    if (userIdAtStart == null) return;

    try {
      final profile = await _service.getMyProfile();
      if (_user?.id != userIdAtStart) return;
      _username = profile?['username'] as String?;
    } catch (_) {
      if (_user?.id != userIdAtStart) return;
      _username = null;
    }
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.signIn(username: username, password: password);
      return true;
    } on AuthServiceException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Login gagal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.signUp(
        username: username,
        password: password,
        confirmPassword: confirmPassword,
      );
      return true;
    } on AuthServiceException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Registrasi gagal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.signOut();
    } on AuthServiceException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Logout gagal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> claimDeviceCollections(String deviceId) async {
    if (!isAuthenticated) return 0;
    return _service.claimDeviceCollections(deviceId);
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}