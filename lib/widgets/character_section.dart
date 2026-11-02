import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../l10n/app_localizations.dart';
import '../models/character_item.dart';
import 'cover_image.dart';

class CharacterSection extends StatelessWidget {
  final List<KarakterAnime> characters;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;
  final VoidCallback? onSeeAll;

  const CharacterSection({
    super.key,
    required this.characters,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (isLoading) return _buildShimmer(theme);

    if (hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingM),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.characterLoadFailed,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text(l10n.tryAgain, style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      );
    }

    if (characters.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.characterSection,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: Text(l10n.seeAll, style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingS),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: characters.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSizes.spacingS),
            itemBuilder: (context, index) {
              final c = characters[index];
              return _CharacterCard(
                karakter: c,
                onTap: () => CharacterDetailSheet.show(context, c),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 18,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSizes.spacingS),
            itemBuilder: (_, __) => Container(
              width: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final KarakterAnime karakter;
  final VoidCallback onTap;

  const _CharacterCard({required this.karakter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: Stack(
                children: [
                  CoverImage(
                    url: karakter.imageUrl,
                    width: 100,
                    height: 110,
                  ),
                  if (karakter.isMain)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.characterMain,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              karakter.nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            if (karakter.voiceActorNama != null)
              Text(
                karakter.voiceActorNama!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CharacterDetailSheet extends StatelessWidget {
  final KarakterAnime karakter;

  const CharacterDetailSheet({super.key, required this.karakter});

  static void show(BuildContext context, KarakterAnime c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => CharacterDetailSheet(karakter: c),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final c = karakter;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingM,
            0,
            AppSizes.spacingM,
            AppSizes.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    child: CoverImage(
                      url: c.imageUrl,
                      width: 100,
                      height: 140,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.nama,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (c.namaNative != null && c.namaNative != c.nama) ...[
                          const SizedBox(height: 2),
                          Text(
                            c.namaNative!,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: c.isMain
                                ? AppColors.primaryGreen
                                    .withValues(alpha: 0.15)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            c.roleLabelOf(l10n),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: c.isMain
                                  ? AppColors.primaryGreen
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (c.voiceActorNama != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.mic, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  c.voiceActorNama!,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (c.gender != null || c.age != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (c.gender != null) c.gender!,
                              if (c.age != null)
                                l10n.characterYearsOld(c.age!),
                            ].join(' · '),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (c.deskripsi != null && c.deskripsi!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  l10n.characterAbout,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _cleanHtml(c.deskripsi!),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.spacingL),
            ],
          ),
        );
      },
    );
  }

  String _cleanHtml(String raw) {
    return raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'~!.*?!~', dotAll: true), '[spoiler]')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}