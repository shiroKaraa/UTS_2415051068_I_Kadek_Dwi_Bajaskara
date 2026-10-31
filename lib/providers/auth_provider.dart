import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, guest }

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
  String? _displayName;
  String? _avatarEmoji;
  StreamSubscription<AuthState>? _sub;
  String _bgPreset = 'default';

  AuthStatus get status => _status;
  User? get user => _user;
  String? get username => _username;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isGuest => _status == AuthStatus.guest;
  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _user?.id;
  String? get displayName => _displayName;
  String? get avatarEmoji => _avatarEmoji;
  String get bgPreset => _bgPreset;

  Future<void> setBgPreset(String preset) async {
    _bgPreset = preset;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_bg_${_user?.id ?? "guest"}', preset);
    } catch (_) {}
  }

  Future<void> _loadLocalBgPreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bgPreset =
          prefs.getString('profile_bg_${_user?.id ?? "guest"}') ?? 'default';
      notifyListeners();
    } catch (_) {
      _bgPreset = 'default';
      notifyListeners();
    }
  }

  void _init() async {
    _sub = _service.onAuthStateChange.listen((state) async {
      final user = state.session?.user;
      if (user != null) {
        if (_user?.id == user.id && _username != null) {
          _status = AuthStatus.authenticated;
          notifyListeners();
          return;
        }
        _user = user;
        _status = AuthStatus.authenticated;
        await _loadProfile();
        await _loadLocalBgPreset();
        if (_user?.id == user.id) notifyListeners();
      } else {
        if (_status == AuthStatus.guest) return;
        final prefs = await SharedPreferences.getInstance();
        final isGuestSaved = prefs.getBool('is_guest_mode') ?? false;
        _status = isGuestSaved ? AuthStatus.guest : AuthStatus.unauthenticated;
        Future.microtask(() async {
          await _loadLocalBgPreset();
          notifyListeners();
        });
      }
    });

    final current = _service.currentUser;
    if (current != null) {
      _user = current;
      _status = AuthStatus.authenticated;

      _loadProfile()
          .timeout(const Duration(seconds: 5))
          .then((_) async {
        await _loadLocalBgPreset();
        if (_user?.id == current.id) notifyListeners();
      }).catchError((_) async {
        await _loadLocalBgPreset();
        if (_user?.id == current.id) notifyListeners();
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      final isGuestSaved = prefs.getBool('is_guest_mode') ?? false;
      _status = isGuestSaved ? AuthStatus.guest : AuthStatus.unauthenticated;
      
      Future.microtask(() async {
        await _loadLocalBgPreset();
        notifyListeners();
      });
    }
  }

  Future<void> _loadProfile() async {
    final userIdAtStart = _user?.id;
    if (userIdAtStart == null) return;
    try {
      final profile = await _service.getMyProfile();
      if (_user?.id != userIdAtStart) return;
      _username = profile?['username'] as String?;
      _displayName = profile?['display_name'] as String?;
      _avatarEmoji = profile?['avatar_emoji'] as String?;
    } catch (_) {
      if (_user?.id != userIdAtStart) return;
      _username = null;
      _displayName = null;
      _avatarEmoji = null;
    }
  }

  Future<bool> signIn(
      {required String username, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.signIn(username: username, password: password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest_mode', false);
      
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
          confirmPassword: confirmPassword);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest_mode', false);

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

  Future<bool> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (_status == AuthStatus.guest) {
        _user = null;
        _username = null;
        _displayName = null;
        _avatarEmoji = null;
        _bgPreset = 'default';
        _status = AuthStatus.unauthenticated;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_guest_mode', false);
        
        return true;
      }

      await _service.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest_mode', false);

      return true;
    } on AuthServiceException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Logout gagal: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(
      {required String displayName, required String avatarEmoji}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.updateProfile(
          displayName: displayName, avatarEmoji: avatarEmoji);
      _displayName = displayName;
      _avatarEmoji = avatarEmoji;
      return true;
    } on AuthServiceException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Gagal update profil: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.updatePassword(newPassword);
      return true;
    } on AuthServiceException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Gagal update password: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    _user = null;
    _username = null;
    _displayName = null;
    _avatarEmoji = null;
    _status = AuthStatus.guest;
    _bgPreset = 'default';
    _isLoading = false;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest_mode', true);
    
    _loadLocalBgPreset();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}