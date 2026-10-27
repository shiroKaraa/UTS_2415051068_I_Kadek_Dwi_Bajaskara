import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/collection_entry.dart';
import '../providers/collection_provider.dart';
import '../services/backup_service.dart';

enum _ImportMode { merge, replace }

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final BackupService _backupService = BackupService();
  bool _isProcessing = false;
  String? _progressText;

  Future<void> _eksporData() async {
    final collection = context.read<CollectionProvider>();
    if (collection.allEntries.isEmpty) {
      _snack('Koleksi masih kosong, tidak ada yang bisa diekspor.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _progressText = null;
    });

    try {
      final path = await _backupService.exportToJson(collection.allEntries);
      if (!mounted) return;
      _snack('Backup berhasil dibuat: ${path.split('/').last}');
    } on BackupException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal mengekspor: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressText = null;
        });
      }
    }
  }

  Future<void> _imporData() async {
    final collection = context.read<CollectionProvider>();

    // 1. Pilih file
    const typeGroup = XTypeGroup(label: 'JSON', extensions: ['json']);
    final XFile? pickedFile;
    try {
      pickedFile = await openFile(acceptedTypeGroups: [typeGroup]);
    } catch (e) {
      _snack('Gagal membuka file picker: $e');
      return;
    }
    if (pickedFile == null) return;

    // 2. Baca & validasi
    setState(() {
      _isProcessing = true;
      _progressText = 'Membaca file...';
    });

    List<EntriKoleksi> parsed;
    try {
      final jsonString = await pickedFile.readAsString();
      parsed = await _backupService.importFromJson(jsonString);
    } on BackupException catch (e) {
      if (!mounted) return;
      _snack(e.message);
      setState(() {
        _isProcessing = false;
        _progressText = null;
      });
      return;
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal membaca file: $e');
      setState(() {
        _isProcessing = false;
        _progressText = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _progressText = null;
    });

    // 3. Pilih mode (Merge / Replace)
    final mode = await _pilihMode(parsed.length);
    if (mode == null) return;

    // 4. Deduplikasi (hanya untuk mode Merge)
    List<EntriKoleksi> toImport = parsed;
    int skipped = 0;
    if (mode == _ImportMode.merge) {
      final existingKeys = collection.allEntries
          .map(_backupService.entryKey)
          .toSet();
      toImport = parsed.where((e) {
        return !existingKeys.contains(_backupService.entryKey(e));
      }).toList();
      skipped = parsed.length - toImport.length;
    }

    if (toImport.isEmpty) {
      _snack(
        'Semua ${parsed.length} entri sudah ada di koleksi. Tidak ada yang diimpor.',
      );
      return;
    }

    // 5. Konfirmasi Replace (hapus semua data lama)
    if (mode == _ImportMode.replace) {
      final yakin = await _konfirmasiReplace(parsed.length);
      if (yakin != true) return;
    }

    // 6. Proses impor
    setState(() {
      _isProcessing = true;
      _progressText = mode == _ImportMode.replace
          ? 'Menghapus koleksi lama...'
          : 'Mengimpor ${toImport.length} entri...';
    });

    try {
      // 6a. Replace: hapus semua dulu
      if (mode == _ImportMode.replace) {
        final deleted = await collection.deleteAll();
        if (collection.errorMessage != null) {
          _snack(collection.errorMessage!);
          return;
        }
        if (!mounted) return;
        setState(() {
          _progressText = 'Menghapus $deleted entri lama... Mengimpor...';
        });
      }

      // 6b. Batch insert
      final inserted = await collection.createEntries(toImport);

      if (!mounted) return;

      if (inserted == 0 && collection.errorMessage != null) {
        _snack('Gagal impor: ${collection.errorMessage}');
        return;
      }

      // 6c. Refresh untuk memastikan sinkron
      await collection.refresh();

      if (!mounted) return;

      final parts = <String>['$inserted entri berhasil diimpor'];
      if (skipped > 0) parts.add('$skipped dilewati (duplikat)');
      _snack(parts.join(', ') + '.');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal impor: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressText = null;
        });
      }
    }
  }

  Future<_ImportMode?> _pilihMode(int totalEntri) async {
    return showDialog<_ImportMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Impor Data'),
        content: Text(
          'File berisi $totalEntri entri.\n\n'
          '• Gabung (Merge): tambah entri baru, lewati duplikat.\n'
          '• Ganti Semua (Replace): hapus koleksi lama, lalu impor file ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _ImportMode.merge),
            child: const Text('Gabung'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _ImportMode.replace),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Ganti Semua'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _konfirmasiReplace(int totalEntri) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Semua Koleksi?'),
        content: Text(
          'Semua koleksi saat ini akan DIHAPUS, lalu diganti dengan '
          '$totalEntri entri dari file ini.\n\n'
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Ya, Ganti Semua'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
          // ===== EKSPOR =====
          Card(
            elevation: 0,
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Column(
                children: [
                  const Icon(Icons.backup,
                      size: 64, color: AppColors.primaryGreen),
                  const SizedBox(height: AppSizes.spacingM),
                  const Text(
                    'Cadangkan Koleksi Anda',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  const Text(
                    'Ekspor koleksi ke file JSON. Anda bisa menyimpannya di '
                    'Google Drive, Files, atau tempat aman lainnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _eksporData,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        'Ekspor Data (${collection.allEntries.length} item)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.spacingL),

          // ===== IMPOR =====
          Card(
            elevation: 0,
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Column(
                children: [
                  const Icon(Icons.restore,
                      size: 64, color: AppColors.infoBlue),
                  const SizedBox(height: AppSizes.spacingM),
                  const Text(
                    'Pulihkan Koleksi',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  const Text(
                    'Pilih file JSON backup yang sebelumnya Anda ekspor. '
                    'Anda bisa memilih untuk menggabungkan atau mengganti koleksi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _imporData,
                      icon: const Icon(Icons.file_open),
                      label: const Text('Impor Data dari File'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.infoBlue,
                        side: const BorderSide(color: AppColors.infoBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.spacingL),

          // ===== PROGRESS =====
          if (_isProcessing)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  if (_progressText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _progressText!,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

          const SizedBox(height: AppSizes.spacingL),

          // ===== INFO =====
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            decoration: BoxDecoration(
              color: AppColors.infoBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppColors.infoBlue),
                const SizedBox(width: AppSizes.spacingS),
                Expanded(
                  child: Text(
                    'Data koleksi Anda tetap aman di server (Supabase). '
                    'Fitur backup ini berguna untuk migrasi antar perangkat '
                    'atau menyimpan salinan lokal.',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}