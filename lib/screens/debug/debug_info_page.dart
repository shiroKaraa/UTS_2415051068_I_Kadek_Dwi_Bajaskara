import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/app_sizes.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/collection_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../services/anilist_service.dart';
import '../../models/media_type_enum.dart';

class DebugInfoPage extends StatefulWidget {
  const DebugInfoPage({super.key});

  @override
  State<DebugInfoPage> createState() => _DebugInfoPageState();
}

class _DebugInfoPageState extends State<DebugInfoPage> {
  String _appVersion = '-';
  String _buildNumber = '-';
  bool _isPinging = false;
  String _supabaseStatus = 'Belum dicek';
  String _anilistStatus = 'Belum dicek';
  String _connectivityStatus = 'Belum dicek';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    _runPing();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _runPing() async {
    setState(() => _isPinging = true);
    final collection = context.read<CollectionProvider>();
    final supaOk = await collection.retryConnection();
    if (!mounted) return;
    final anilist = AniListService();
    String aniStatus;
    try {
      final result = await anilist.fetchPage(jenis: JenisMedia.anime, page: 1);
      aniStatus = result.media.isNotEmpty ? 'Tersambung' : 'Kosong';
    } catch (_) {
      aniStatus = 'Gagal';
    } finally {
      anilist.dispose();
    }

    if (!mounted) return;
    setState(() {
      _connectivityStatus = supaOk ? 'Online' : 'Offline';
      _supabaseStatus = supaOk ? 'Tersambung' : 'Gagal';
      _anilistStatus = aniStatus;
      _isPinging = false;
    });
  }

  String _buildDebugText(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final collection = context.read<CollectionProvider>();
    final buf = StringBuffer();
    buf.writeln('=== Tsuzuki Debug Info ===');
    buf.writeln('App Version: $_appVersion+$_buildNumber');
    buf.writeln('Flutter: ${Platform.version.split(' ').first}');
    buf.writeln('Platform: ${Platform.operatingSystem}');
    buf.writeln('');
    buf.writeln('Connectivity: $_connectivityStatus');
    buf.writeln('Supabase: $_supabaseStatus');
    buf.writeln('AniList: $_anilistStatus');
    buf.writeln('');
    buf.writeln('Theme: ${settings.themeMode.name}');
    buf.writeln('Locale: ${settings.locale.languageCode}');
    buf.writeln('Card Size: ${settings.cardSize.name}');
    buf.writeln('Items Per Row: ${settings.itemsPerRow}');
    buf.writeln('NSFW: ${settings.enableNsfw}');
    buf.writeln('Collection Count: ${collection.allEntries.length}');
    buf.writeln('Offline: ${collection.isOffline}');
    if (collection.errorMessage != null) {
      buf.writeln('Last Error: ${collection.errorMessage}');
    }
    buf.writeln('===========================');
    return buf.toString();
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final text = _buildDebugText(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copiedToClipboard)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debugInfo),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Info',
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
          _section('Informasi Aplikasi', [
            _tile('Versi', _appVersion),
            _tile('Build Number', _buildNumber),
            _tile('Flutter', Platform.version.split(' ').first),
            _tile('Platform', Platform.operatingSystem),
            _tile('Debug Mode', kDebugMode ? 'Ya' : 'Tidak'),
          ]),
          const SizedBox(height: AppSizes.spacingM),
          _section('Konektivitas', [
            _tile('Koneksi Internet', _connectivityStatus),
            _tile('Supabase Backend', _supabaseStatus),
            _tile('AniList API', _anilistStatus),
            const SizedBox(height: AppSizes.spacingS),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _isPinging
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: Text(_isPinging ? 'Menguji...' : 'Test Ulang Koneksi'),
                onPressed: _isPinging ? null : _runPing,
              ),
            ),
          ]),
          const SizedBox(height: AppSizes.spacingM),
          _section('Pengaturan Aktif', [
            _tile('Tema', settings.themeMode.name),
            _tile('Bahasa', settings.locale.languageCode),
            _tile('Ukuran Card', settings.cardSize.name),
            _tile('Item per Baris', settings.itemsPerRow.toString()),
            _tile('NSFW', settings.enableNsfw ? 'Aktif' : 'Nonaktif'),
            _tile('Image Cache Limit', settings.limitImageCache ? 'Aktif' : 'Nonaktif'),
          ]),
          const SizedBox(height: AppSizes.spacingM),
          _section('Status Koleksi', [
            _tile('Total Entri', collection.allEntries.length.toString()),
            _tile('Status Offline', collection.isOffline ? 'Ya' : 'Tidak'),
            _tile('Loading', collection.isLoading ? 'Ya' : 'Tidak'),
            if (collection.errorMessage != null)
              _tile('Error Terakhir', collection.errorMessage!),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.spacingS),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}