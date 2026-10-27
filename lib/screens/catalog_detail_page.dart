import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/catalog_item.dart';
import '../widgets/cover_image.dart';
import '../widgets/media_type_chip.dart';
import 'entry_form_page.dart';

class CatalogDetailPage extends StatelessWidget {
  final ItemKatalog item;

  const CatalogDetailPage({super.key, required this.item});

  String _bersihkanSinopsis(String? raw) {
    if (raw == null || raw.isEmpty) return 'Tidak ada sinopsis.';
    var text = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    return text.isEmpty ? 'Tidak ada sinopsis.' : text;
  }

  Color _getColorForType(String label) {
    switch (label) {
      case 'Anime':
        return AppColors.typeAnime;
      case 'Manga':
        return AppColors.typeManga;
      case 'Manhwa':
        return AppColors.typeManhwa;
      case 'Manhua':
        return AppColors.typeManhua;
      default:
        return AppColors.typeLainnya;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sinopsis = _bersihkanSinopsis(item.sinopsis);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.displayTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'poster_${item.malId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: Stack(
                    children: [
                      CoverImage(
                        url: item.coverUrl,
                        width: 180,
                        height: 270,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.75),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppSizes.spacingS,
                        left: AppSizes.spacingS,
                        child: MediaTypeChip(
                          label: item.jenis.label,
                          dotColor: _getColorForType(item.jenis.label),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              item.displayTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
            if (item.judul.isNotEmpty && item.judul != item.displayTitle) ...[
              const SizedBox(height: AppSizes.spacingXs),
              Text(
                item.judul,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingM),
            Wrap(
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingS,
              children: [
                if (item.skor != null)
                  _infoChip(
                    context,
                    icon: Icons.star_rounded,
                    label: item.skor!.toStringAsFixed(1),
                    color: AppColors.goldPrimary,
                  ),
                if (item.total != null)
                  _infoChip(
                    context,
                    icon: Icons.menu_book_outlined,
                    label:
                        '${item.total} ${item.jenis.satuanProgres}',
                    color: AppColors.infoBlue,
                  ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingL),
            Text(
              'Sinopsis',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.spacingM),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(
                sinopsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacingXl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryFormPage(item: item),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah ke Koleksi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacingM,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSizes.spacingXs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}