import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_extras.dart';
import '../core/app_sizes.dart';
import '../l10n/app_localizations.dart';
import '../models/collection_entry.dart';
import '../models/custom_label.dart';
import '../models/status_collection_enum.dart';
import '../providers/label_provider.dart';
import 'cover_image.dart';
import 'media_type_chip.dart';
import 'progress_bar.dart';

class CollectionListCard extends StatelessWidget {
  final EntriKoleksi entri;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onIncrement;

  const CollectionListCard({
    super.key,
    required this.entri,
    required this.isProcessing,
    required this.onTap,
    required this.onLongPress,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final x = context.extras;

    final total = entri.total;
    final hasTotal = total != null && total > 0;
    final progress = hasTotal ? (entri.progres / total).clamp(0.0, 1.0) : 0.0;
    final statusColor = x.statusColor(entri.status);
    final done = entri.status == StatusKoleksi.selesai;
    final unit = entri.jenis.satuanProgres(l10n);
    final label = context.select<LabelProvider, LabelKustom?>(
        (p) => p.findById(entri.labelId));
    final hasCatatan = entri.catatan != null && entri.catatan!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    child: CoverImage(
                        url: entri.coverUrl, width: 84, height: 126),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: MediaTypeChip(
                      label: entri.jenis.label(l10n),
                      dotColor: x.typeColor(entri.jenis),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 126,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entri.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusPill(
                              label: entri.status.netralLabel(l10n),
                              color: statusColor),
                          if (label != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: x.statusColor(entri.status)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.label_outline,
                                        size: 10, color: x.anime),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        label.nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: x.anime,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (hasCatatan) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.sticky_note_2_outlined,
                                size: 11,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                entri.catatan!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entri.progres} / ${hasTotal ? total : '?'} $unit',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (!done)
                            SizedBox(
                              height: 32,
                              child: FilledButton.tonal(
                                onPressed: isProcessing
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        onIncrement();
                                      },
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(52, 32),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                ),
                                child: isProcessing
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Text('+1',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ProgressBar(value: progress, color: statusColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      );
}