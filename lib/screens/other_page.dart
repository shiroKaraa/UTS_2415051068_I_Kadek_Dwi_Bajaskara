import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'about_page.dart';
import 'category_page.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navOther),
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
            title: Text(l10n.statistics),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.label_outline, color: iconColor),
            title: Text(l10n.manageCategories),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.storage_outlined, color: iconColor),
            title: Text(l10n.storage),
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
            title: Text(l10n.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite_border, color: iconColor),
            title: Text(l10n.supportUs),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.supportThankYou)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: Text(l10n.about),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline, color: iconColor),
            title: Text(l10n.help),
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