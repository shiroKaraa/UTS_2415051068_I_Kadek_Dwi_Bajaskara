import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../providers/auth_provider.dart';

class GuestInfoPage extends StatelessWidget {
  const GuestInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Tamu'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 44,
                    color: AppColors.infoBlue,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                'Halo, Tamu!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXs),
              Text(
                'Kamu sedang menjelajah sebagai tamu. '
                'Beberapa fitur tidak tersedia sebelum kamu masuk.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSizes.spacingXl),
              _SectionCard(
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                title: 'Yang bisa kamu lakukan',
                items: const [
                  'Jelajahi katalog anime, manga, manhwa, dan manhua.',
                  'Cari dan filter judul sesukamu.',
                  'Lihat detail, rating, dan sinopsis.',
                  'Ubah tema (gelap/terang) dan bahasa aplikasi.',
                  'Atur ukuran card dan tata letak tampilan.',
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              _SectionCard(
                icon: Icons.cancel_outlined,
                iconColor: AppColors.danger,
                title: 'Yang butuh akun',
                items: const [
                  'Menyimpan judul ke koleksi pribadi.',
                  'Mencatat progres episode/chapter.',
                  'Membuat label dan mengelompokkan koleksi.',
                  'Backup & restore data koleksi.',
                  'Sinkronisasi data antar perangkat.',
                ],
              ),
              const SizedBox(height: AppSizes.spacingXl),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Daftar / Masuk Akun'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              OutlinedButton(
                onPressed: () {
                  _showConfirmDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Lanjut sebagai Tamu'),
              ),

              const SizedBox(height: AppSizes.spacingL),
              Center(
                child: Text(
                  'Kamu bisa mendaftar kapan saja untuk menyimpan koleksi.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Lanjut sebagai Tamu?'),
        content: const Text(
          'Data koleksi tidak akan tersimpan di akun. '
          'Pastikan kamu memahami keterbatasan mode tamu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Ya, Lanjut'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    context.read<AuthProvider>().continueAsGuest();
    
    Navigator.pop(context);
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingS),
            ...items.map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          it,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}