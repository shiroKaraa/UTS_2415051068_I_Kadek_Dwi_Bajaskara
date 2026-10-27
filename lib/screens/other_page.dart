import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'settings_page.dart';

class OtherPage extends StatelessWidget {
  const OtherPage({super.key});

  Future<void> _hapusCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cache Lokal?'),
        content: const Text(
          'Data koleksi yang tersimpan di perangkat akan dihapus. '
          'Data utama di server tetap aman dan akan dimuat ulang saat online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('cache_koleksi_'));
      for (final key in keys.toList()) {
        await prefs.remove(key);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache lokal berhasil dihapus.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus cache: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Lainnya')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.settings_outlined, color: iconColor),
            title: const Text('Pengaturan'),
            subtitle: const Text('Tema aplikasi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.cleaning_services_outlined, color: iconColor),
            title: const Text('Hapus Cache Lokal'),
            subtitle: const Text('Bersihkan data koleksi yang tersimpan offline'),
            onTap: () => _hapusCache(context),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.help_outline, color: iconColor),
            title: const Text('Bantuan'),
            subtitle: const Text('FAQ & panduan penggunaan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: const Text('Tentang'),
            subtitle: const Text('Info aplikasi & developer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}