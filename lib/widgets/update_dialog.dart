import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/update_info.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  final UpdateService service;

  const UpdateDialog({
    super.key,
    required this.info,
    required this.service,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0;
  File? _downloadedFile;
  String? _error;

  Future<void> _download() async {
    setState(() {
      _isDownloading = true;
      _error = null;
      _progress = 0;
    });

    try {
      final file = await widget.service.downloadApk(
        widget.info,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      setState(() {
        _downloadedFile = file;
        _isDownloading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _error = 'Gagal mengunduh. Periksa koneksi internet.';
      });
    }
  }

  Future<void> _install() async {
    if (_downloadedFile == null) return;
    final result = await OpenFilex.open(_downloadedFile!.path);
    if (result.type != ResultType.done && mounted) {
      setState(() {
        _error = 'Tidak dapat membuka installer. '
            'Aktifkan "Install unknown apps" untuk Tsuzuki di Pengaturan.';
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.system_update, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Update Tersedia',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi ${widget.info.version}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Ukuran: ${_formatBytes(widget.info.apkSize)}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            const Text('Catatan Rilis:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(AppSizes.spacingS),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.info.body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: AppSizes.spacingM),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 4),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSizes.spacingM),
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDownloading ? null : () => Navigator.pop(context),
          child: const Text('Nanti'),
        ),
        if (_downloadedFile == null)
          ElevatedButton.icon(
            onPressed: _isDownloading ? null : _download,
            icon: _isDownloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isDownloading ? 'Mengunduh...' : 'Unduh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.black,
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _install,
            icon: const Icon(Icons.install_mobile),
            label: const Text('Install'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.black,
            ),
          ),
      ],
    );
  }
}