import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../models/collection_entry.dart';
import '../../models/status_collection_enum.dart';
import '../../providers/collection_provider.dart';
import 'cover_image.dart';

class CollectionCard extends StatelessWidget {
  final EntriKoleksi entri;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CollectionCard({
    super.key,
    required this.entri,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final progress = (entri.total != null && entri.total! > 0)
        ? (entri.progres / entri.total!).clamp(0.0, 1.0)
        : 0.0;
    final bool isSelesai = entri.status == StatusKoleksi.selesai;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(
                    child: CoverImage(url: entri.coverUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (entri.isFavorite)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(
                        Icons.star,
                        color: AppColors.goldPrimary,
                        size: 20,
                      ),
                    ),
                  if (!isSelesai && entri.total != null)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Semantics(
                        button: true,
                        label: 'Tambah progres ${entri.judul}',
                        child: Material(
                          color: AppColors.primaryGreen,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () async {
                              final provider = context.read<CollectionProvider>();
                              final messenger = ScaffoldMessenger.of(context);

                              final result = await provider.incrementProgress(entri);

                              if (!context.mounted) return;

                              if (result == HasilIncrement.ok) {
                                messenger.showSnackBar(SnackBar(content: Text(l10n.progressAdded)));
                              } else if (result == HasilIncrement.offline) {
                                messenger.showSnackBar(SnackBar(content: Text(l10n.offlineMode)));
                              } else if (result == HasilIncrement.alreadyCompleted) {
                                messenger.showSnackBar(SnackBar(content: Text(l10n.congratsCompleted)));
                              } else {
                                messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.errorLoadData)));
                              }
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Icon(Icons.add, color: Colors.black, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entri.judul,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            entri.status.netralLabel(l10n),
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
          ),
          Semantics(
            label: '${l10n.progress} ${entri.progres} / ${entri.total ?? "?"}',
            child: Text(
              '${entri.progres}/${entri.total ?? "?"}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: AppColors.primaryGreen,
            minHeight: 3,
          ),
        ],
      ),
    );
  }
}