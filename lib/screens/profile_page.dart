import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

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
              child: const Text(
                'IB',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'I Kadek Dwi Bajaskara',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.nimLabel}: 2415051068',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.classLabel}: PTI 5A',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
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
              title: Text(l10n.deviceId),
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
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}