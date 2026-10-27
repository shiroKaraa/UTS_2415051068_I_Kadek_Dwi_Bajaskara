import 'package:flutter/material.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';
import 'storage_page.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lainnya'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.auto_stories,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          const Divider(),
          ListTile(
            leading: Icon(Icons.insights_outlined, color: iconColor),
            title: const Text('Statistik'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.storage_outlined, color: iconColor),
            title: const Text('Data dan penyimpanan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StoragePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: iconColor),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite_border, color: iconColor),
            title: const Text('Dukung Kami'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terima kasih atas dukungan Anda!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: const Text('Tentang'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: iconColor),
            title: const Text('Bantuan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpPage()),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}