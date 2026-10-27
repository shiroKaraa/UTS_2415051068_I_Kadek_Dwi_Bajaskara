import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServiceException implements Exception {
  final String message;
  AuthServiceException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _emailDomain = 'tsuzuki-auth.com';

  String _emailFromUsername(String username) {
    return '${username.trim().toLowerCase()}@$_emailDomain';
  }

  String normalizeUsername(String username) => username.trim().toLowerCase();

  String? validateUsername(String username) {
    final u = normalizeUsername(username);
    if (u.isEmpty) return 'Username tidak boleh kosong.';
    if (u.length < 3) return 'Username minimal 3 karakter.';
    if (u.length > 20) return 'Username maksimal 20 karakter.';
    final regex = RegExp(r'^[a-z0-9_]+$');
    if (!regex.hasMatch(u)) {
      return 'Username hanya boleh huruf kecil, angka, dan underscore.';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password tidak boleh kosong.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    return null;
  }

  Future<bool> isUsernameAvailable(String username) async {
    final u = normalizeUsername(username);
    try {
      final result = await _supabase.rpc(
        'check_username_available',
        params: {'p_username': u},
      );
      return result == true;
    } catch (e) {
      throw AuthServiceException('Gagal memeriksa username: $e');
    }
  }

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    final u = normalizeUsername(username);

    final errU = validateUsername(u);
    if (errU != null) throw AuthServiceException(errU);
    final errP = validatePassword(password);
    if (errP != null) throw AuthServiceException(errP);

    try {
      final res = await _supabase.auth.signInWithPassword(
        email: _emailFromUsername(u),
        password: password,
      );
      if (res.user == null) {
        throw AuthServiceException(
            'Login gagal. Periksa username dan password.');
      }
    } on AuthRetryableFetchException {
      throw AuthServiceException(
          'Tidak ada koneksi internet. Login membutuhkan internet.');
    } on AuthServiceException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthServiceException(_mapAuthApiError(e));
    } catch (e) {
      throw AuthServiceException('Login gagal: $e');
    }
  }

  Future<AuthResponse> signUp({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final u = normalizeUsername(username);

    final errU = validateUsername(u);
    if (errU != null) throw AuthServiceException(errU);
    final errP = validatePassword(password);
    if (errP != null) throw AuthServiceException(errP);
    if (password != confirmPassword) {
      throw AuthServiceException('Konfirmasi password tidak cocok.');
    }

    try {
      final available = await isUsernameAvailable(u);
      if (!available) {
        throw AuthServiceException('Username "$u" sudah dipakai.');
      }
    } on AuthServiceException {
      rethrow;
    }

    AuthResponse response;
    try {
      response = await _supabase.auth.signUp(
        email: _emailFromUsername(u),
        password: password,
      );
    } on AuthRetryableFetchException {
      throw AuthServiceException(
          'Tidak ada koneksi internet. Registrasi membutuhkan internet.');
    } on AuthApiException catch (e) {
      throw AuthServiceException(_mapAuthApiError(e));
    } catch (e) {
      throw AuthServiceException('Registrasi gagal: $e');
    }

    final user = response.user;
    if (user == null) {
      throw AuthServiceException('Registrasi gagal: user tidak terbentuk.');
    }

    if (response.session == null) {
      try {
        await _supabase.rpc('delete_own_account');
      } catch (_) {}
      throw AuthServiceException(
        'Registrasi berhasil tetapi sesi belum aktif. '
        'Pastikan "Confirm email" dimatikan di Dashboard Supabase '
        '(Authentication → Providers → Email).',
      );
    }

    try {
      final profile = await _supabase
          .from('profiles')
          .select('id, username')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        try {
          await _supabase.rpc('delete_own_account');
        } catch (_) {}
        throw AuthServiceException('Username "$u" sudah dipakai.');
      }
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      try {
        await _supabase.rpc('delete_own_account');
      } catch (_) {}
      throw AuthServiceException('Registrasi gagal: $e');
    }

    return response;
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthServiceException('Gagal logout: $e');
    }
  }

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Session? get currentSession => _supabase.auth.currentSession;

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, username, created_at')
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String avatarEmoji,
  }) async {
    final user = currentUser;
    if (user == null) throw AuthServiceException('Pengguna belum login.');
    
    try {
      await _supabase.from('profiles').update({
        'display_name': displayName.trim(),
        'avatar_emoji': avatarEmoji,
      }).eq('id', user.id);
    } catch (e) {
      throw AuthServiceException('Gagal update profil: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthApiException catch (e) {
      if (e.message.toLowerCase().contains('password should be')) {
        throw AuthServiceException('Password terlalu lemah (minimal 6 karakter).');
      }
      throw AuthServiceException(e.message);
    } catch (e) {
      throw AuthServiceException('Gagal update password: $e');
    }
  }

  Future<int> claimDeviceCollections(String deviceId) async {
    if (currentUser == null) return 0;
    try {
      final res = await _supabase.rpc(
        'claim_device_collections',
        params: {'p_device_id': deviceId},
      );
      if (res is int) return res;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  String _mapAuthApiError(AuthApiException e) {
    final msg = e.message.toLowerCase();
    final code = (e.code ?? '').toLowerCase();

    if (code == 'over_email_send_rate_limit' ||
        msg.contains('email rate limit')) {
      return 'Batas pengiriman email tercapai. Coba lagi dalam 1 jam.';
    }
    if (code == 'over_request_rate_limit' ||
        msg.contains('rate limit') ||
        msg.contains('too many')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
    }
    if (msg.contains('invalid login credentials')) {
      return 'Username atau password salah.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered')) {
      return 'Username sudah dipakai.';
    }
    if (msg.contains('password should be')) {
      return 'Password terlalu lemah (minimal 6 karakter).';
    }
    return e.message;
  }
}