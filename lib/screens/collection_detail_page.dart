import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/collection_entry.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import '../widgets/cover_image.dart';
import '../widgets/status_chip.dart';
import 'edit_entry_page.dart';

class CollectionDetailPage extends StatelessWidget {
  final EntriKoleksi entri;

  const CollectionDetailPage({super.key, required this.entri});
  Color _statusColor(StatusKoleksi status) {
    switch (status) {
      case StatusKoleksi.direncanakan:
        return AppColors.infoBlue;
      case StatusKoleksi.sedang:
        return AppColors.primaryGreen;
      case StatusKoleksi.selesai:
        return AppColors.goldPrimary;
      case StatusKoleksi.ditunda:
        return AppColors.typeLainnya;
      case StatusKoleksi.dihentikan:
        return AppColors.typeManga;
    }
  }

  Future<void> _konfirmasiHapus(BuildContext context) async {
    final collection = context.read<CollectionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Koleksi?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${entri.judul}" dari koleksi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final berhasil = await collection.deleteEntry(entri);

    if (!context.mounted) return;

    if (berhasil) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Berhasil dihapus dari koleksi.'),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () async {
              if (collection.isOffline) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tidak dapat mengurungkan saat offline.',
                    ),
                  ),
                );
                return;
              }
              final ok = await collection.createEntry(entri);
              if (!ok) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      collection.errorMessage ?? 'Gagal mengurungkan.',
                    ),
                  ),
                );
              }
            },
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(collection.errorMessage ?? 'Gagal menghapus.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (entri.total != null && entri.total! > 0)
        ? (entri.progres / entri.total!).clamp(0.0, 1.0)
        : 0.0;
    final statusColor = _statusColor(entri.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(entri.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEntryPage(entri: entri),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Hapus',
            onPressed: () => _konfirmasiHapus(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                child: Stack(
                  children: [
                    CoverImage(
                      url: entri.coverUrl,
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
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSizes.spacingS,
                      left: AppSizes.spacingS,
                      child: StatusChip(
                        label: entri.status.netralLabel,
                        backgroundColor: statusColor.withValues(alpha: 0.2),
                        textColor: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              entri.judul,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: AppSizes.spacingXs),
            Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSizes.spacingXs),
                Text(
                  entri.jenis.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Icon(Icons.flag_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSizes.spacingXs),
                Text(
                  entri.status.label(entri.jenis),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingL),
            Card(
              elevation: 0,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progres ${entri.jenis.satuanProgres}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${entri.progres} / ${entri.total ?? "?"}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (entri.rating != null) ...[
              const SizedBox(height: AppSizes.spacingM),
              Card(
                elevation: 0,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.star_rounded,
                      color: AppColors.goldPrimary),
                  title: const Text('Rating'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < entri.rating!
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppColors.goldPrimary,
                        size: 20,
                      );
                    }),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'Catatan',
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
                (entri.catatan == null || entri.catatan!.isEmpty)
                    ? 'Tidak ada catatan.'
                    : entri.catatan!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: (entri.catatan == null || entri.catatan!.isEmpty)
                      ? FontStyle.italic
                      : FontStyle.normal,
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
                      builder: (context) => EditEntryPage(entri: entri),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Edit Entri Ini'),
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _konfirmasiHapus(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus dari Koleksi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.5),
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
}