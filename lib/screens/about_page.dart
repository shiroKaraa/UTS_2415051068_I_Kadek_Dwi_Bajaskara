import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Image.asset(
              'assets/logo/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tsuzuki',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('${l10n.version} 1.0.0', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Text(
              l10n.appDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(l10n.developer),
              subtitle: const Text('I Kadek Dwi Bajaskara (2415051068)'),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: Text(l10n.course),
              subtitle: const Text('Pemrograman Mobile - PTI 5A'),
            ),
            ListTile(
              leading: const Icon(Icons.api),
              title: Text(l10n.dataSource),
              subtitle: const Text('AniList GraphQL API & Supabase'),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.copyright,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}