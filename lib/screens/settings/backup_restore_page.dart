import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/collection_entry.dart';
import '../../providers/collection_provider.dart';
import '../../services/backup_service.dart';

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

  Future<void> _eksporData(AppLocalizations l10n) async {
    final collection = context.read<CollectionProvider>();
    if (collection.allEntries.isEmpty) {
      _snack(l10n.errorEmptyData);
      return;
    }

    setState(() {
      _isProcessing = true;
      _progressText = null;
    });

    try {
      final path = await _backupService.exportToJson(collection.allEntries);
      if (!mounted) return;
      _snack('${l10n.backupRestore}: ${path.split('/').last}');
    } on BackupException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } catch (e) {
      if (!mounted) return;
      _snack('${l10n.errorLoadData}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressText = null;
        });
      }
    }
  }

  Future<void> _imporData(AppLocalizations l10n) async {
    final collection = context.read<CollectionProvider>();
    const typeGroup =
        XTypeGroup(label: 'JSON', extensions: ['json']);
    final XFile? pickedFile;
    try {
      pickedFile = await openFile(acceptedTypeGroups: [typeGroup]);
    } catch (e) {
      _snack('${l10n.errorLoadData}: $e');
      return;
    }
    if (pickedFile == null) return;

    setState(() {
      _isProcessing = true;
      _progressText = l10n.backupRestore;
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
      _snack('${l10n.errorLoadData}: $e');
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

    final mode = await _pilihMode(parsed.length, l10n);
    if (mode == null) return;

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
      _snack('${l10n.noResults}: ${parsed.length}');
      return;
    }

    if (mode == _ImportMode.replace) {
      final yakin = await _konfirmasiReplace(parsed.length, l10n);
      if (yakin != true) return;
    }

    setState(() {
      _isProcessing = true;
      _progressText = l10n.backupRestore;
    });

    try {
      if (mode == _ImportMode.replace) {
        await collection.deleteAll();
        if (collection.errorMessage != null) {
          _snack(collection.errorMessage!);
          return;
        }
        if (!mounted) return;
        setState(() {
          _progressText = l10n.delete;
        });
      }

      final inserted = await collection.createEntries(toImport);

      if (!mounted) return;

      if (inserted == 0 && collection.errorMessage != null) {
        _snack(collection.errorMessage!);
        return;
      }

      await collection.refresh();

      if (!mounted) return;

      final parts = <String>['+$inserted'];
      if (skipped > 0) parts.add('-$skipped');
      _snack(parts.join(', '));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _snack('${l10n.errorLoadData}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _progressText = null;
        });
      }
    }
  }

  Future<_ImportMode?> _pilihMode(int totalEntri, AppLocalizations l10n) async {
    return showDialog<_ImportMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupRestore),
        content: Text('$totalEntri ${l10n.navCollection}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _ImportMode.merge),
            child: Text(l10n.apply),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _ImportMode.replace),
            style:
                TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<bool?> _konfirmasiReplace(int totalEntri, AppLocalizations l10n) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('$totalEntri ${l10n.navCollection}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;
    final collection = context.watch<CollectionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupRestore)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
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
                  Text(
                    l10n.backupRestore,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    l10n.backupDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isProcessing ? null : () => _eksporData(l10n),
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        '${l10n.backupRestore} '
                        '(${collection.allEntries.length})',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
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
                  Text(
                    l10n.backupRestore,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    l10n.backupDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isProcessing ? null : () => _imporData(l10n),
                      icon: const Icon(Icons.file_open),
                      label: Text(l10n.backupRestore),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.infoBlue,
                        side:
                            const BorderSide(color: AppColors.infoBlue),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
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
                    l10n.storageDataDesc,
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