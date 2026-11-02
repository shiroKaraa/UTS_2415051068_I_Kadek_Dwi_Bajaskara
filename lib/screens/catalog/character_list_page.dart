import 'package:flutter/material.dart';
import '../../core/app_sizes.dart';
import '../../l10n/app_localizations.dart';
import '../../models/character_item.dart';
import '../../services/anilist_service.dart';
import '../../widgets/character_section.dart' show CharacterDetailSheet;
import '../../widgets/cover_image.dart';
import '../../widgets/error_view.dart';

class CharacterListPage extends StatefulWidget {
  final int anilistId;
  final String judul;

  const CharacterListPage({
    super.key,
    required this.anilistId,
    required this.judul,
  });

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  final AniListService _service = AniListService();
  final ScrollController _scroll = ScrollController();
  final List<KarakterAnime> _characters = [];
  bool _isLoading = false;
  bool _hasNext = true;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 300) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _service.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_isLoading || !_hasNext || _error != null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _service.fetchCharacters(
        widget.anilistId,
        page: _page,
        perPage: 25,
      );
      if (!mounted) return;
      setState(() {
        _characters.addAll(result.characters);
        _hasNext = result.hasNextPage;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _error = e is RateLimitException
            ? l10n.rateLimitError
            : e is NetworkException
                ? l10n.networkError
                : l10n.characterLoadFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.characterSection} · ${widget.judul}',
        ),
      ),
      body: _error != null && _characters.isEmpty
          ? ErrorView(
              message: _error!,
              onRetry: () {
                setState(() => _error = null);
                _load();
              },
            )
          : CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSizes.spacingM),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 110,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = _characters[index];
                        return _CharacterGridItem(
                          karakter: c,
                          onTap: () => CharacterDetailSheet.show(context, c),
                        );
                      },
                      childCount: _characters.length,
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.spacingM),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.spacingM),
                      child: Center(
                        child: Column(
                          children: [
                            Text(_error!,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _error = null);
                                _load();
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CharacterGridItem extends StatelessWidget {
  final KarakterAnime karakter;
  final VoidCallback onTap;

  const _CharacterGridItem({
    required this.karakter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CoverImage(url: karakter.imageUrl),
                  if (karakter.isMain)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.characterMain,
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
          ),
          const SizedBox(height: 4),
          Text(
            karakter.nama,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            karakter.roleLabelOf(AppLocalizations.of(context)!),
            style: TextStyle(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}