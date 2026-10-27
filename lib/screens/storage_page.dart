import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  bool _isLoading = true;
  int _imageCacheSize = 0;
  int _collectionDataSize = 0;
  int _translationDataSize = 0;

  @override
  void initState() {
    super.initState();
    _hitungUkuran();
  }

  Future<void> _hitungUkuran() async {
    setState(() => _isLoading = true);

    final imageCache = PaintingBinding.instance.imageCache;
    final imgSize = imageCache.currentSizeBytes;

    int collectionSize = 0;
    int translationSize = 0;

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      final value = prefs.getString(key);
      if (value == null) continue;

      final byteSize = utf8.encode(value).length;
      if (key.startsWith('cache_koleksi_')) {
        collectionSize += byteSize;
      } else if (key.startsWith('tr_id_')) {
        translationSize += byteSize;
      }
    }

    if (!mounted) return;
    setState(() {
      _imageCacheSize = imgSize;
      _collectionDataSize = collectionSize;
      _translationDataSize = translationSize;
      _isLoading = false;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _hapusCacheGambar(AppLocalizations l10n) async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await _hitungUkuran();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n.storage}: ${l10n.clearAll}')),
    );
  }

  Future<void> _hapusCacheData(
    AppLocalizations l10n, {
    required bool includeCollection,
    required bool includeTranslation,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.storageDataDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) {
      if (includeCollection && k.startsWith('cache_koleksi_')) return true;
      if (includeTranslation && k.startsWith('tr_id_')) return true;
      return false;
    }).toList(growable: false);

    for (final key in keys) {
      await prefs.remove(key);
    }

    await _hitungUkuran();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n.storage}: ${l10n.clearAll}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final totalSize = _imageCacheSize + _collectionDataSize + _translationDataSize;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.storage),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _hitungUkuran,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              children: [
                Card(
                  elevation: 0,
                  color: theme.cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.spacingM),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.pie_chart_outline,
                          size: 48,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          l10n.storage,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: AppSizes.spacingXs),
                        Text(
                          _formatBytes(totalSize),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingL),
                Text(
                  l10n.activityDetails,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Card(
                  elevation: 0,
                  color: theme.cardColor,
                  child: ListTile(
                    leading: const Icon(
                      Icons.image_outlined,
                      color: AppColors.infoBlue,
                    ),
                    title: Text(l10n.storage),
                    subtitle: Text(_formatBytes(_imageCacheSize)),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: l10n.delete,
                      onPressed: _imageCacheSize > 0
                          ? () => _hapusCacheGambar(l10n)
                          : null,
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: theme.cardColor,
                  child: ListTile(
                    leading: const Icon(
                      Icons.storage_outlined,
                      color: AppColors.goldPrimary,
                    ),
                    title: Text(l10n.storageData),
                    subtitle: Text(_formatBytes(_collectionDataSize)),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: l10n.delete,
                      onPressed: _collectionDataSize > 0
                          ? () => _hapusCacheData(
                                l10n,
                                includeCollection: true,
                                includeTranslation: false,
                              )
                          : null,
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: theme.cardColor,
                  child: ListTile(
                    leading: const Icon(
                      Icons.translate,
                      color: AppColors.typeManhua,
                    ),
                    title: Text(l10n.synopsis),
                    subtitle: Text(_formatBytes(_translationDataSize)),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: l10n.delete,
                      onPressed: _translationDataSize > 0
                          ? () => _hapusCacheData(
                                l10n,
                                includeCollection: false,
                                includeTranslation: true,
                              )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingL),
                Center(
                  child: Text(
                    l10n.storageDataDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
    );
  }
}