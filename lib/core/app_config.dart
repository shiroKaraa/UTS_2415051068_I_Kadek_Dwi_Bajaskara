import 'package:flutter_dotenv/flutter_dotenv.dart';

class KonfigurasiApp {
  KonfigurasiApp._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;

  static void ensureConfigured() {
    if (!isConfigured) {
      throw StateError(
          'SUPABASE_URL atau SUPABASE_ANON_KEY belum diset di .env. '
          'Pastikan URL berawalan https:// dan Key tidak kosong.');
    }
  }
}