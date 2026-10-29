import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/collection_entry.dart';
import '../../providers/collection_provider.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/progress_bar.dart';
import 'edit_entry_page.dart';

class CollectionDetailPage extends StatelessWidget {
  final int id;

  const CollectionDetailPage({super.key, required this.id});

  Future<void> _konfirmasiHapus(
      BuildContext context, AppLocalizations l10n, EntriKoleksi entri) async {
    final collection = context.read<CollectionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.delete} "${entri.judul}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.delete),
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
          content: Text(l10n.entryDeleted),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () async => await collection.createEntry(entri),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(collection.errorMessage ?? l10n.errorLoadData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final entri = context
        .select<CollectionProvider, EntriKoleksi?>((p) => p.findById(id));

    if (entri == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.errorEmptyData)),
      );
    }

    final progress = (entri.total != null && entri.total! > 0)
        ? (entri.progres / entri.total!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(entri.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              entri.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: entri.isFavorite ? Colors.redAccent : null,
            ),
            tooltip:
                entri.isFavorite ? l10n.favoriteRemoved : l10n.favoriteAdded,
            onPressed: () async {
              final collection = context.read<CollectionProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final wasFavorite = entri.isFavorite;
              final berhasil = await collection.toggleFavorite(entri);
              if (!context.mounted) return;
              if (berhasil) {
                messenger.showSnackBar(
                  SnackBar(
                      content: Text(wasFavorite
                          ? l10n.favoriteRemoved
                          : l10n.favoriteAdded)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.edit,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditEntryPage(entri: entri)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: l10n.delete,
            onPressed: () => _konfirmasiHapus(context, l10n, entri),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'poster_collection_${entri.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: CoverImage(
                      url: entri.coverUrl, width: 180, height: 270),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(entri.judul,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
            const SizedBox(height: AppSizes.spacingXs),
            Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSizes.spacingXs),
                Text(entri.jenis.label(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: AppSizes.spacingM),
                Icon(Icons.flag_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSizes.spacingXs),
                Text(entri.status.label(entri.jenis, l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSizes.spacingL),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${l10n.progress} ${entri.jenis.satuanProgres(l10n)}',
                            style: theme.textTheme.bodyMedium),
                        Text('${entri.progres} / ${entri.total ?? "?"}',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    ProgressBar(value: progress),
                    const SizedBox(height: AppSizes.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.remove),
                          onPressed: entri.progres > 0
                              ? () async {
                                  final provider =
                                      context.read<CollectionProvider>();
                                  final ok = await provider
                                      .decrementProgress(entri);
                                  if (!context.mounted) return;
                                  if (!ok) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                provider.errorMessage ??
                                                    'Gagal')));
                                  }
                                }
                              : null,
                        ),
                        const SizedBox(width: AppSizes.spacingL),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final provider =
                                context.read<CollectionProvider>();
                            final result =
                                await provider.incrementProgress(entri);
                            if (!context.mounted) return;

                            if (result == HasilIncrement.ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(l10n.progressAdded)));
                            } else if (result == HasilIncrement.offline) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(l10n.offlineMode)));
                            } else if (result ==
                                HasilIncrement.alreadyCompleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(l10n.congratsCompleted)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          provider.errorMessage ??
                                              l10n.errorLoadData)));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (entri.rating != null) ...[
              const SizedBox(height: AppSizes.spacingM),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.star_rounded,
                      color: AppColors.goldPrimary),
                  title: const Text('Rating'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < entri.rating!
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.goldPrimary,
                              size: 20,
                            )),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingL),
            Text(l10n.note,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
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
                    ? l10n.noNotes
                    : entri.catatan!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: (entri.catatan == null || entri.catatan!.isEmpty)
                      ? FontStyle.italic
                      : FontStyle.normal,
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