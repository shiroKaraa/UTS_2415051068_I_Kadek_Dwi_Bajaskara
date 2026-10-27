import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_sizes.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  Future<void> _hapusCache(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Cache Lokal?'),
        content: const Text(
          'Data koleksi yang tersimpan di perangkat akan dihapus. '
          'Data utama di server tetap aman dan akan dimuat ulang saat online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
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

      messenger.showSnackBar(
        const SnackBar(content: Text('Cache lokal berhasil dihapus.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menghapus cache: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data dan Penyimpanan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Cache Koleksi Offline'),
                  subtitle: const Text('Data lokal yang digunakan saat tidak ada internet.'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Hapus Cache',
                    onPressed: () => _hapusCache(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          const Center(
            child: Text(
              'Hapus cache tidak akan menghapus data dari server (Supabase).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}