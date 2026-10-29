import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/catalog_item.dart';
import '../../services/anilist_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/media_type_chip.dart';
import '../collection/entry_form_page.dart';

class CatalogDetailPage extends StatefulWidget {
  final ItemKatalog item;

  const CatalogDetailPage({super.key, required this.item});

  @override
  State<CatalogDetailPage> createState() => _CatalogDetailPageState();
}

class _CatalogDetailPageState extends State<CatalogDetailPage> {
  final TranslationService _translation = TranslationService();
  final AniListService _anilist = AniListService();

  ItemKatalog? _detail;
  bool _isLoadingDetail = false;
  bool _detailFailed = false;

  String? _sinopsisTerjemahan;
  bool _isTranslating = false;
  String _rawSinopsis = '';

  @override
  void initState() {
    super.initState();
    _rawSinopsis = _bersihkanSinopsis(widget.item.sinopsis);
    _muatDetailLengkap();
  }

  @override
  void dispose() {
    _anilist.dispose();
    super.dispose();
  }

  Future<void> _muatDetailLengkap() async {
    if (widget.item.sinopsis != null && widget.item.sinopsis!.isNotEmpty) {
      setState(() => _detail = widget.item);
      return;
    }

    setState(() => _isLoadingDetail = true);
    try {
      final json = await _anilist.fetchDetail(widget.item.anilistId);
      if (!mounted) return;
      final full = ItemKatalog.fromAniList(json, widget.item.jenis);
      setState(() {
        _detail = full;
        _rawSinopsis = _bersihkanSinopsis(full.sinopsis);
        _isLoadingDetail = false;
      });
      final l10n = AppLocalizations.of(context)!;
      if (l10n.localeName.startsWith('id')) _mulaiTerjemahan();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detailFailed = true;
        _isLoadingDetail = false;
      });
    }
  }

  Future<void> _mulaiTerjemahan() async {
    if (_isTranslating) return;
    if (_sinopsisTerjemahan != null) return;
    if (_rawSinopsis.isEmpty) return;

    setState(() => _isTranslating = true);

    final hasil = await _translation.translateToId(
      _rawSinopsis,
      anilistId: widget.item.anilistId,
    );

    if (!mounted) return;
    setState(() {
      _sinopsisTerjemahan = hasil;
      _isTranslating = false;
    });
  }

  String _bersihkanSinopsis(String? raw) {
    if (raw == null || raw.isEmpty) return '';
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
    return text;
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isId = l10n.localeName.startsWith('id');
    final item = _detail ?? widget.item;

    final sinopsisTampil = !isId
        ? _rawSinopsis
        : (_sinopsisTerjemahan ?? _rawSinopsis);
    final sinopsisKosong = _rawSinopsis.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'poster_${item.anilistId}',
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
                          label: item.jenis.label(l10n),
                          dotColor: _getColorForType(item.jenis.label(l10n)),
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
                if (item.tahunRilis != null)
                  _infoChip(
                    context,
                    icon: Icons.calendar_today,
                    label: item.tahunRilis.toString(),
                    color: AppColors.infoBlue,
                  ),
                if (item.statusTayang != null)
                  _infoChip(
                    context,
                    icon: Icons.play_circle_outline,
                    label: item.statusTayang!,
                    color: AppColors.primaryGreen,
                  ),
                if (item.total != null)
                  _infoChip(
                    context,
                    icon: Icons.menu_book_outlined,
                    label:
                        '${item.total} ${item.jenis.satuanProgres(l10n)}',
                    color: AppColors.typeAnime,
                  ),
              ],
            ),
            if (item.genres.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacingM),
              Wrap(
                spacing: AppSizes.spacingS,
                runSpacing: AppSizes.spacingS,
                children:
                    item.genres.map((g) => Chip(label: Text(g))).toList(),
              ),
            ],
            if (_detailFailed) ...[
              const SizedBox(height: AppSizes.spacingM),
              Container(
                padding: const EdgeInsets.all(AppSizes.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: AppColors.goldPrimary),
                    const SizedBox(width: AppSizes.spacingS),
                    Expanded(
                      child: Text(
                        'Detail lengkap gagal dimuat. Menampilkan data ringkas.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacingL),
            Row(
              children: [
                Text(
                  l10n.synopsis,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (isId && _isTranslating) ...[
                  const SizedBox(width: AppSizes.spacingS),
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                if (isId && !_isTranslating && _sinopsisTerjemahan != null) ...[
                  const SizedBox(width: AppSizes.spacingS),
                  Icon(Icons.translate,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                ],
                if (_isLoadingDetail) ...[
                  const SizedBox(width: AppSizes.spacingS),
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
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
                sinopsisKosong ? l10n.noSynopsis : sinopsisTampil,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle:
                      sinopsisKosong ? FontStyle.italic : FontStyle.normal,
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
                label: Text(l10n.addToCollection),
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