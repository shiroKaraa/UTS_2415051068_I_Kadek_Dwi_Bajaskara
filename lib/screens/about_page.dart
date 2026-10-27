import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
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
            const Text('Versi 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text(
              'Aplikasi pelacak progres tontonan Anime dan bacaan Komik (Manga, Manhwa, Manhua).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Developer'),
              subtitle: Text('I Kadek Dwi Bajaskara (2415051068)'),
            ),
            const ListTile(
              leading: Icon(Icons.school),
              title: Text('Mata Kuliah'),
              subtitle: Text('Pemrograman Mobile - PTI 5A'),
            ),
            const ListTile(
              leading: Icon(Icons.api),
              title: Text('Sumber Data'),
              subtitle: Text('AniList GraphQL API & Supabase'),
            ),
            const SizedBox(height: 24),
            const Text(
              '© 2026 Tsuzuki App',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}