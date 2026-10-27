import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('Tsuzuki', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              const Text('Versi 1.0.0'),
              const SizedBox(height: 24),
              const Text(
                'Aplikasi pelacak progres tontonan Anime dan bacaan Komik (Manga, Manhwa, Manhua).',
                textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
}