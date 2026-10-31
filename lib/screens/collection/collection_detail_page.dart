import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/collection_entry.dart';
import '../../models/custom_label.dart';
import '../../providers/collection_provider.dart';
import '../../providers/label_provider.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/progress_bar.dart';
import 'edit_entry_page.dart';

class CollectionDetailPage extends StatelessWidget {
  final int id;

  const CollectionDetailPage({super.key, required this.id});

  Future<void> _konfirmasiHapus(
      BuildContext context, AppLocalizations l10n, EntriKoleksi entri) async {
    final collection = context.read<CollectionProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.delete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.delete} "${entri.judul}"?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDeleteInfoRow(
              Icons.category_outlined,
              entri.jenis.label(l10n),
            ),
            _buildDeleteInfoRow(
              Icons.flag_outlined,
              entri.status.label(entri.jenis, l10n),
            ),
            _buildDeleteInfoRow(
              Icons.play_circle_outline,
              '${entri.progres}/${entri.total ?? "?"} '
                  '${entri.jenis.satuanProgres(l10n)}',
            ),
            if (entri.rating != null)
              _buildDeleteInfoRow(
                Icons.star_rounded,
                'Rating: ${entri.rating}/5',
              ),
            if (entri.catatan != null && entri.catatan!.isNotEmpty)
              _buildDeleteInfoRow(
                Icons.sticky_note_2_outlined,
                'Catatan: ${entri.catatan!.length} karakter',
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: Colors.redAccent),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Progress, rating, dan catatan akan hilang. '
                      'Tindakan ini dapat di-undo lewat SnackBar.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
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

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    navigator.pop();

    final berhasil = await collection.deleteEntry(entri);
    if (!berhasil) {
      messenger.showSnackBar(
        SnackBar(
            content: Text(collection.errorMessage ?? l10n.errorLoadData)),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.entryDeleted),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () async {
            final ok = await collection.createEntry(entri);
            if (!ok && collection.errorMessage != null) {
              messenger.showSnackBar(
                SnackBar(content: Text(collection.errorMessage!)),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDeleteInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
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

    final label = context.select<LabelProvider, LabelKustom?>(
        (p) => p.findById(entri.labelId));

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

                if (label != null) ...[
                  const SizedBox(width: AppSizes.spacingM),
                  const Icon(Icons.label_outline,
                      size: 16, color: AppColors.infoBlue),
                  const SizedBox(width: AppSizes.spacingXs),
                  Text(label.nama,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.infoBlue,
                          fontWeight: FontWeight.bold)),
                ],
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
                    _ProgressControls(entri: entri),
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

class _ProgressControls extends StatefulWidget {
  final EntriKoleksi entri;
  const _ProgressControls({required this.entri});

  @override
  State<_ProgressControls> createState() => _ProgressControlsState();
}

class _ProgressControlsState extends State<_ProgressControls> {
  bool _busy = false;

  Future<void> _run({required bool increment}) async {
    if (_busy) return;
    setState(() => _busy = true);

    final provider = context.read<CollectionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    messenger.clearSnackBars();
    final minWait = Future.delayed(const Duration(milliseconds: 450));

    HasilIncrement result;
    try {
      if (increment) {
        result = await provider.incrementProgress(widget.entri);
      } else {
        result = await provider.decrementProgress(widget.entri);
      }
    } catch (_) {
      result = HasilIncrement.error;
    }

    await minWait;
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == HasilIncrement.inFlight) return;

    switch (result) {
      case HasilIncrement.ok:
        if (increment) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.progressAdded)),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.progressRemoved)),
          );
        }
        break;
      case HasilIncrement.offline:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.offlineMode)),
        );
        break;
      case HasilIncrement.alreadyCompleted:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.congratsCompleted)),
        );
        break;
      case HasilIncrement.error:
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? l10n.errorLoadData),
          ),
        );
        break;
      case HasilIncrement.inFlight:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entri = widget.entri;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          icon: _busy && entri.progres > 0
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.remove),
          onPressed: (entri.progres <= 0 || _busy)
              ? null
              : () => _run(increment: false),
        ),
        const SizedBox(width: AppSizes.spacingL),
        IconButton.filledTonal(
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          onPressed: _busy ? null : () => _run(increment: true),
        ),
      ],
    );
  }
}