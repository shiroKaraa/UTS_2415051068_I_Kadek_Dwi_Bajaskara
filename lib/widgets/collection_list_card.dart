import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_extras.dart';
import '../core/app_sizes.dart';
import '../core/title_actions.dart';
import '../l10n/app_localizations.dart';
import '../models/collection_entry.dart';
import '../models/status_collection_enum.dart';
import 'cover_image.dart';
import 'media_type_chip.dart';
import 'progress_bar.dart';

class CollectionListCard extends StatelessWidget {
  final EntriKoleksi entri;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onIncrement;
  final bool isSelectionMode;
  final bool isSelected;

  const CollectionListCard({
    super.key,
    required this.entri,
    required this.isProcessing,
    required this.onTap,
    required this.onLongPress,
    required this.onIncrement,
    this.isSelectionMode = false,
    this.isSelected = false,
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
    final hasCatatan = entri.catatan != null && entri.catatan!.isNotEmpty;
    const double contentHeight = 140;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2.5)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelectionMode) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 60),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
                  height: contentHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onLongPress: () => showTitleActions(
                          context,
                          title: entri.judul,
                        ),
                        child: Text(
                          entri.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _StatusPill(
                        label: entri.status.netralLabel(l10n),
                        color: statusColor,
                      ),
                      if (hasCatatan) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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