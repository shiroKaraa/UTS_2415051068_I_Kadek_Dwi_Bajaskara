import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _konfirmasiLogout(
      BuildContext context, AppLocalizations l10n) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Anda akan keluar dari akun ini. Koleksi tetap tersimpan di akun '
          'dan dapat diakses kembali setelah login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    final username = auth.username ?? '-';
    final email = auth.user?.email ?? '-';
    final initial = username.isNotEmpty
        ? username.substring(0, 1).toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '@$username',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 48),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.sourceData),
              subtitle: Text(l10n.sourceDataDesc),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_outlined),
              title: Text(l10n.storageData),
              subtitle: Text(l10n.storageDataDesc),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: Text('${l10n.deviceId} (debug)'),
              subtitle: Text(settings.deviceId ?? l10n.loadingId),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  final id = settings.deviceId;
                  if (id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.deviceIdNotAvailable)),
                    );
                    return;
                  }
                  await Clipboard.setData(ClipboardData(text: id));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.idCopied(id))),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _konfirmasiLogout(context, l10n),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}