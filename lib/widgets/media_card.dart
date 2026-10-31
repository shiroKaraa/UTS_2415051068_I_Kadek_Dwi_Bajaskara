import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_extras.dart'; 
import '../../core/app_sizes.dart';
import '../../core/title_actions.dart';
import '../../models/catalog_item.dart';
import 'adult_badge.dart';
import 'cover_image.dart';
import 'media_type_chip.dart';

class MediaCard extends StatelessWidget {
  final ItemKatalog item;
  final VoidCallback onTap;
  final VoidCallback? onAddProgress;
  final VoidCallback? onSearch;
  final double? width;
  final String? heroTag;
  final bool showAdultBadge;

  const MediaCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onAddProgress,
    this.onSearch,
    this.width,
    this.heroTag,
    this.showAdultBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final satuan = item.jenis.satuanProgres(l10n);
    final x = context.extras;

    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CoverImage(url: item.coverUrl),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
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
          if (onAddProgress != null)
            Positioned(
              bottom: AppSizes.spacingS,
              right: AppSizes.spacingS,
              child: Material(
                color: AppColors.primaryGreen,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onAddProgress,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.add, color: Colors.black, size: 20),
                  ),
                ),
              ),
            ),
          Positioned(
            top: AppSizes.spacingS,
            left: AppSizes.spacingS,
            child: MediaTypeChip(
              label: item.jenis.label(l10n),
              dotColor: x.typeColor(item.jenis),
            ),
          ),
          if (showAdultBadge && item.isAdult)
            const Positioned(
              top: AppSizes.spacingS,
              right: AppSizes.spacingS,
              child: AdultBadge(),
            ),
        ],
      ),
    );

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: AppSizes.aspectRatioPoster,
              child: heroTag != null
                  ? Hero(tag: heroTag!, child: poster)
                  : poster,
            ),
            const SizedBox(height: AppSizes.spacingS),
            GestureDetector(
              onLongPress: () => showTitleActions(
                context,
                title: item.displayTitle,
                onSearch: onSearch,
              ),
              child: Text(
                item.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Text(
              '${item.total ?? "?"} $satuan',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

}