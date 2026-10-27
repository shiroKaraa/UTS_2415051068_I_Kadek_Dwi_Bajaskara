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
      throw BackupException('Collection is empty, nothing to export.');
    }

    final List<Map<String, dynamic>> jsonList =
        entries.map((e) => e.toBackupJson()).toList();
    final String jsonString =
        const JsonEncoder.withIndent('  ').convert(jsonList);

    // Gunakan temporary directory agar tidak menumpuk permanen.
    final directory = await getTemporaryDirectory();
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
      subject: 'Tsuzuki Collection Backup',
      text:
          'Tsuzuki collection backup file (${entries.length} items, ~$sizeKb KB). '
          'Store this file in a safe place (Google Drive, Files, etc).',
    );

    return file.path;
  }

  Future<List<EntriKoleksi>> importFromJson(String jsonString) async {
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw BackupException('File is not valid JSON.');
    }

    if (decoded is! List) {
      throw BackupException(
        'Invalid file format. Must be a JSON array.',
      );
    }

    final entries = <EntriKoleksi>[];
    for (int i = 0; i < decoded.length; i++) {
      final raw = decoded[i];
      if (raw is! Map<String, dynamic>) {
        throw BackupException('Entry #${i + 1}: invalid format.');
      }

      final judul = raw['judul'];
      if (judul == null || (judul is String && judul.trim().isEmpty)) {
        throw BackupException('Entry #${i + 1}: "judul" is required.');
      }
      if (raw['jenis'] == null) {
        throw BackupException('Entry #${i + 1}: "jenis" is required.');
      }
      if (raw['status'] == null) {
        throw BackupException('Entry #${i + 1}: "status" is required.');
      }

      try {
        entries.add(EntriKoleksi.fromJson(raw));
      } catch (e) {
        throw BackupException(
          'Entry #${i + 1}: failed to read (${e.toString()}).',
        );
      }
    }

    if (entries.isEmpty) {
      throw BackupException('File is empty, no data to import.');
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