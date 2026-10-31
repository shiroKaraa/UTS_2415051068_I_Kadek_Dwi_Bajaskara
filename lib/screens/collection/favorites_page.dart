import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_sizes.dart';
import '../../l10n/app_localizations.dart';
import '../../models/card_size_enum.dart';
import '../../models/collection_entry.dart';
import '../../models/media_type_enum.dart';
import '../../providers/collection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/collection_card.dart';
import 'collection_detail_page.dart';
import 'edit_entry_page.dart';

enum _FavFilter { all, anime, comic }

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  _FavFilter _filter = _FavFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final collection = context.watch<CollectionProvider>();

    final cardSize =
        context.select<SettingsProvider, CardSize>((s) => s.cardSize);
    final itemsPerRow =
        context.select<SettingsProvider, int>((s) => s.itemsPerRow);
    final screenWidth = MediaQuery.sizeOf(context).width;
    const padding = AppSizes.spacingM * 2;
    const spacing = 16.0;
    final columnWidth =
        (screenWidth - padding - (spacing * (itemsPerRow - 1))) / itemsPerRow;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final posterHeight = columnWidth / (2 / 3);
    final mainAxisExtent = posterHeight + (cardSize.textExtra * textScale);

    final allFavorites =
        collection.allEntries.where((e) => e.isFavorite).toList();

    final favorites = allFavorites.where((e) {
      switch (_filter) {
        case _FavFilter.all:
          return true;
        case _FavFilter.anime:
          return e.jenis == JenisMedia.anime;
        case _FavFilter.comic:
          return e.jenis == JenisMedia.manga ||
              e.jenis == JenisMedia.manhwa ||
              e.jenis == JenisMedia.manhua;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoriteTitle)),
      body: Column(
        children: [
          if (allFavorites.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingM,
                  vertical: AppSizes.spacingS),
              child: Row(
                children: [
                  _chip(l10n.all, _FavFilter.all),
                  const SizedBox(width: 8),
                  _chip(l10n.anime, _FavFilter.anime),
                  const SizedBox(width: 8),
                  _chip(l10n.comic, _FavFilter.comic),
                ],
              ),
            ),
          Expanded(
            child: allFavorites.isEmpty
                ? EmptyView(
                    title: l10n.noFavoritesTitle,
                    subtitle: l10n.noFavoritesDesc,
                    icon: Icons.favorite_border_rounded,
                  )
                : favorites.isEmpty
                    ? EmptyView(
                        title: l10n.noResults,
                        subtitle: l10n.noResultsDesc,
                        icon: Icons.search_off,
                        actionLabel: l10n.resetFilter,
                        onAction: () =>
                            setState(() => _filter = _FavFilter.all),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSizes.spacingM),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: itemsPerRow,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: mainAxisExtent,
                        ),
                        itemCount: favorites.length,
                        itemBuilder: (context, index) {
                          final entri = favorites[index];
                          return CollectionCard(
                            key: ValueKey(entri.id),
                            entri: entri,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CollectionDetailPage(id: entri.id!),
                                ),
                              );
                            },
                            onLongPress: () =>
                                _showQuickMenu(context, entri, l10n),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _FavFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (selected) {
        if (selected) setState(() => _filter = value);
      },
    );
  }

  void _showQuickMenu(
      BuildContext context, EntriKoleksi entri, AppLocalizations l10n) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final collection = context.read<CollectionProvider>();

    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(sheetCtx);
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => EditEntryPage(entri: entri),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete, color: Colors.redAccent),
              title: Text(l10n.delete,
                  style: const TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(sheetCtx);
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
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.category_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(entri.jenis.label(l10n),
                                    style:
                                        const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.flag_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    entri.status.label(entri.jenis, l10n),
                                    style:
                                        const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 16, color: Colors.redAccent),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Data akan dihapus. Bisa di-undo lewat SnackBar.',
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
                        onPressed: () =>
                            Navigator.pop(dialogCtx, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogCtx, true),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;
                final berhasil = await collection.deleteEntry(entri);

                if (berhasil) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.entryDeleted),
                      action: SnackBarAction(
                        label: l10n.undo,
                        onPressed: () => collection.createEntry(entri),
                      ),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                        content: Text(collection.errorMessage ??
                            l10n.errorLoadData)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}