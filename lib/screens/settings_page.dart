import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema Aplikasi'),
            subtitle: Text(
              settings.themeMode == ThemeMode.dark
                  ? 'Gelap'
                  : settings.themeMode == ThemeMode.light
                      ? 'Terang'
                      : 'Ikuti Sistem',
            ),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  context.read<SettingsProvider>().setThemeMode(newMode);
                }
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Gelap')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Terang')),
                DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}