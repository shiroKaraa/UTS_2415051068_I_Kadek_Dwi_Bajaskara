import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/card_size_enum.dart';
import '../../providers/settings_provider.dart';
import 'backup_restore_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(l10n.theme),
            subtitle: Text(
              settings.themeMode == ThemeMode.dark
                  ? l10n.dark
                  : settings.themeMode == ThemeMode.light
                      ? l10n.light
                      : l10n.system,
            ),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  context.read<SettingsProvider>().setThemeMode(newMode);
                }
              },
              items: [
                DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
                DropdownMenuItem(
                    value: ThemeMode.light, child: Text(l10n.light)),
                DropdownMenuItem(
                    value: ThemeMode.system, child: Text(l10n.system)),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              settings.locale.languageCode == 'id' ? 'Indonesia' : 'English',
            ),
            trailing: DropdownButton<String>(
              value: settings.locale.languageCode,
              onChanged: (String? newLang) {
                if (newLang != null) {
                  context.read<SettingsProvider>().setLocale(Locale(newLang));
                }
              },
              items: const [
                DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.grid_view_rounded),
            title: Text(l10n.cardSizeTitle),
            subtitle: Text(l10n.cardSizeSubtitle),
            trailing: DropdownButton<CardSize>(
              value: settings.cardSize,
              onChanged: (CardSize? newSize) {
                if (newSize != null) {
                  context.read<SettingsProvider>().setCardSize(newSize);
                }
              },
              items: CardSize.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.label(l10n)),
                      ))
                  .toList(),
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.backupRestore),
            subtitle: Text(l10n.backupDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupRestorePage()),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: Icon(
              Icons.visibility_off_outlined,
              color: settings.enableNsfw ? Colors.redAccent : null,
            ),
            title: Text(l10n.nsfwSettingsTitle),
            subtitle: Text(l10n.nsfwSettingsSubtitle),
            value: settings.enableNsfw,
            onChanged: (value) async {
              if (value && !settings.enableNsfw) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: Text(l10n.nsfwEnableTitle),
                    content: Text(l10n.nsfwEnableBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent),
                        child: Text(l10n.yes),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
              }

              if (!context.mounted) return;
              await context.read<SettingsProvider>().setEnableNsfw(value);
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.image_outlined),
            title: Text(l10n.imageCache),
            subtitle: Text(l10n.imageCacheDesc),
            value: settings.limitImageCache,
            onChanged: (value) async {
              await context.read<SettingsProvider>().setLimitImageCache(value);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}