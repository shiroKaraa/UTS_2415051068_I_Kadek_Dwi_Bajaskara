import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/collection_entry.dart';

class BackupException implements Exception {
  final String message;
  BackupException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  static const int _currentVersion = 1;

  Future<String> exportToJson(
    List<EntriKoleksi> entries, {
    Rect? sharePositionOrigin,
  }) async {
    if (entries.isEmpty) {
      throw BackupException('Koleksi kosong, tidak ada yang diekspor.');
    }

    final items = entries.map((e) => e.toBackupJson()).toList();
    final payload = {
      'version': _currentVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'items': items,
    };
    final String jsonString =
        const JsonEncoder.withIndent('  ').convert(payload);

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = 'tsuzuki_backup_$timestamp.json';
    final file = File(p.join(directory.path, fileName));
    await file.writeAsString(jsonString);

    final sizeKb = (jsonString.length / 1024).toStringAsFixed(1);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Tsuzuki Collection Backup',
      text:
          'Tsuzuki collection backup file (${entries.length} items, ~$sizeKb KB). '
          'Store this file in a safe place (Google Drive, Files, etc).',
      sharePositionOrigin: sharePositionOrigin,
    );

    try {
      await file.delete();
    } catch (_) {}

    return file.path;
  }

  Future<List<EntriKoleksi>> importFromJson(String jsonString) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw BackupException('File bukan JSON yang valid.');
    }

    List<dynamic> items;
    if (decoded is List) {
      items = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['items'] is List) {
      items = decoded['items'] as List<dynamic>;
    } else {
      throw BackupException(
        'Format file tidak dikenali. Harus berupa array JSON atau objek {items: [...]}.',
      );
    }

    final entries = <EntriKoleksi>[];
    for (int i = 0; i < items.length; i++) {
      final raw = items[i];
      if (raw is! Map<String, dynamic>) {
        throw BackupException('Entri #${i + 1}: format tidak valid.');
      }

      final judul = raw['judul'];
      if (judul == null || (judul is String && judul.trim().isEmpty)) {
        throw BackupException('Entri #${i + 1}: "judul" wajib diisi.');
      }
      if (raw['jenis'] == null) {
        throw BackupException('Entri #${i + 1}: "jenis" wajib diisi.');
      }
      if (raw['status'] == null) {
        throw BackupException('Entri #${i + 1}: "status" wajib diisi.');
      }

      try {
        entries.add(EntriKoleksi.fromJson(raw));
      } catch (e) {
        throw BackupException(
          'Entri #${i + 1}: gagal dibaca (${e.toString()}).',
        );
      }
    }

    if (entries.isEmpty) {
      throw BackupException('File kosong, tidak ada data untuk diimpor.');
    }

    return entries;
  }

  String entryKey(EntriKoleksi e) {
    final id = e.externalId?.trim();
    if (id != null && id.isNotEmpty) {
      return '${e.jenis.name}|id:$id';
    }
    return '${e.jenis.name}|title:${e.judul.trim().toLowerCase()}';
  }
}