import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/collection_entry.dart';

class BackupException implements Exception {
  final String message;
  BackupException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  Future<String> exportToJson(List<EntriKoleksi> entries) async {
    if (entries.isEmpty) {
      throw BackupException('Koleksi kosong, tidak ada yang bisa diekspor.');
    }

    final List<Map<String, dynamic>> jsonList =
        entries.map((e) => e.toBackupJson()).toList();
    final String jsonString =
        const JsonEncoder.withIndent('  ').convert(jsonList);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final fileName = 'tsuzuki_backup_$timestamp.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    final sizeKb = (jsonString.length / 1024).toStringAsFixed(1);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Backup Koleksi Tsuzuki',
      text:
          'File cadangan koleksi Tsuzuki (${entries.length} item, ~$sizeKb KB). '
          'Simpan file ini di tempat aman (Google Drive, Files, dll).',
    );

    return file.path;
  }

  Future<List<EntriKoleksi>> importFromJson(String jsonString) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw BackupException('File bukan JSON yang valid.');
    }

    if (decoded is! List) {
      throw BackupException(
        'Format file tidak valid. Harus berupa array JSON.',
      );
    }

    final entries = <EntriKoleksi>[];
    for (int i = 0; i < decoded.length; i++) {
      final raw = decoded[i];
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