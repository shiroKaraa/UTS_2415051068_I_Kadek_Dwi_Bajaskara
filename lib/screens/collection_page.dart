import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../models/collection_entry.dart';
import '../models/media_type_enum.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import '../widgets/skeleton/skeleton_grid_card.dart';
import '../widgets/skeleton/skeleton_list_card.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/collection_card.dart';
import '../widgets/cover_image.dart';
import 'collection_detail_page.dart';
import 'edit_entry_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    final collection = context.read<CollectionProvider>();
    JenisMedia? tempJenis = collection.filterJenis;
    int? tempRating = collection.filterRating;
    StatusKoleksi? tempStatus = collection.filterStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.activeFilter,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<JenisMedia>(
                    initialValue: tempJenis,
                    decoration: InputDecoration(
                      labelText: l10n.anime,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: null, child: Text(l10n.clearAll)),
                      ...JenisMedia.values.map((j) => DropdownMenuItem(
                          value: j, child: Text(j.label(l10n)))),
                    ],
                    onChanged: (val) => setState(() => tempJenis = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: tempRating,
                    decoration: const InputDecoration(
                      labelText: 'Rating',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: null, child: Text(l10n.clearAll)),
                      ...List.generate(5, (i) => i + 1).map((val) {
                        return DropdownMenuItem(
                            value: val, child: Text('⭐' * val));
                      }),
                    ],
                    onChanged: (val) => setState(() => tempRating = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<StatusKoleksi>(
                    initialValue: tempStatus,
                    decoration: InputDecoration(
                      labelText: l10n.completed,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: null, child: Text(l10n.clearAll)),
                      ...StatusKoleksi.values.map((s) => DropdownMenuItem(
                          value: s, child: Text(s.netralLabel(l10n)))),
                    ],
                    onChanged: (val) => setState(() => tempStatus = val),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(l10n.supportUs),
                    secondary: const Icon(Icons.star,
                        color: AppColors.goldPrimary),
                    value: collection.filterFavorit,
                    onChanged: (val) {
                      collection.setFilterFavorit(val);
                      Navigator.pop(sheetCtx);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            collection.clearFilters();
                            Navigator.pop(sheetCtx);
                          },
                          child: Text(l10n.reset),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            collection.setFilters(
                              jenis: tempJenis,
                              rating: tempRating,
                              status: tempStatus,
                            );
                            Navigator.pop(sheetCtx);
                          },
                          child: Text(l10n.apply),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCollection),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context, l10n),
          ),
          IconButton(
            icon: Icon(
                collection.isListView ? Icons.grid_view : Icons.view_list),
            tooltip: collection.isListView ? 'Grid View' : 'List View',
            onPressed: () => collection.toggleView(),
          ),
          PopupMenuButton<UrutanKoleksi>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) => collection.setUrutan(value),
            itemBuilder: (context) => [
              _buildSortItem(
                  l10n.seeAll, UrutanKoleksi.terbaru, collection.urutan),
              _buildSortItem(
                  l10n.navCollection, UrutanKoleksi.judul, collection.urutan),
              _buildSortItem(
                  l10n.progress, UrutanKoleksi.progres, collection.urutan),
              _buildSortItem(
                  'Rating', UrutanKoleksi.rating, collection.urutan),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => collection.setQuery(val),
              decoration: InputDecoration(
                hintText: l10n.searchInCollection,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          collection.setQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (collection.hasActiveFilters)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt,
                      size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Text(l10n.activeFilter,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primaryGreen)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      collection.clearFilters();
                    },
                    child: Text(l10n.clearAll,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          if (collection.isOffline)
            Container(
              width: double.infinity,
              color: AppColors.goldPrimary.withValues(alpha: 0.2),
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off,
                      size: 16, color: AppColors.goldPrimary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.offlineMode,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => collection.refresh(),
              child: _buildContent(context, collection, l10n),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<UrutanKoleksi> _buildSortItem(
      String label, UrutanKoleksi value, UrutanKoleksi current) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (current == value) const Icon(Icons.check, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CollectionProvider collection,
      AppLocalizations l10n) {
    if (collection.isLoading && collection.allEntries.isEmpty) {
      if (collection.isListView) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (context, index) => const SkeletonListCard(),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          childAspectRatio: 0.6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const SkeletonGridCard(),
      );
    }

    if (collection.errorMessage != null &&
        collection.allEntries.isEmpty) {
      return ErrorView(
        message: collection.errorMessage!,
        onRetry: () => collection.refresh(),
      );
    }

    if (collection.entries.isEmpty) {
      final isFiltered = collection.hasActiveFilters;
      return EmptyView(
        title: isFiltered ? l10n.noResults : l10n.emptyCollection,
        subtitle:
            isFiltered ? l10n.noResultsDesc : l10n.emptyCollectionDesc,
        icon: isFiltered
            ? Icons.search_off
            : Icons.collections_bookmark_outlined,
        actionLabel: isFiltered ? l10n.resetFilter : null,
        onAction: isFiltered ? () => collection.clearFilters() : null,
      );
    }

    if (collection.isListView) {
      return _buildListView(context, collection, l10n);
    } else {
      return _buildGridView(context, collection);
    }
  }

  Widget _buildGridView(
      BuildContext context, CollectionProvider collection) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.6,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: collection.entries.length,
      itemBuilder: (context, index) {
        final entri = collection.entries[index];
        return CollectionCard(
          entri: entri,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailPage(entri: entri),
              ),
            );
          },
          onLongPress: () {
            _showQuickMenu(context, entri);
          },
        );
      },
    );
  }

  Widget _buildListView(BuildContext context,
      CollectionProvider collection, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: collection.entries.length,
      itemBuilder: (context, index) {
        final entri = collection.entries[index];
        final isSelesai = entri.status == StatusKoleksi.selesai;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CoverImage(
                url: entri.coverUrl,
                width: 50,
                height: 70,
              ),
            ),
            title: Text(
              entri.judul,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${entri.status.netralLabel(l10n)} • '
                  '${entri.progres}/${entri.total ?? "?"} '
                  '${entri.jenis.satuanProgres(l10n)}',
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            trailing: !isSelesai && entri.total != null
                ? IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: l10n.progress,
                    style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48)),
                    onPressed: () async {
                      final provider =
                          context.read<CollectionProvider>();
                      final messenger =
                          ScaffoldMessenger.of(context);

                      final ok =
                          await provider.incrementProgress(entri);

                      if (!context.mounted) return;

                      if (!ok) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(provider.errorMessage ??
                                l10n.offlineMode),
                          ),
                        );
                        return;
                      }

                      final updated =
                          provider.allEntries.firstWhere(
                        (e) => e.id == entri.id,
                        orElse: () => entri,
                      );
                      if (updated.status == StatusKoleksi.selesai) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '${l10n.statCompleted}: ${entri.judul}',
                            ),
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(content: Text('${l10n.progress} +1')),
                        );
                      }
                    },
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CollectionDetailPage(entri: entri),
                ),
              );
            },
            onLongPress: () {
              _showQuickMenu(context, entri);
            },
          ),
        );
      },
    );
  }

  void _showQuickMenu(BuildContext context, EntriKoleksi entri) {
    final l10n = AppLocalizations.of(context)!;
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
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: Text(l10n.delete,
                  style: const TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(sheetCtx);

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: Text(l10n.delete),
                    content: Text('${l10n.delete} "${entri.judul}"?'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogCtx, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx, true),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                final berhasil =
                    await collection.deleteEntry(entri);

                if (berhasil) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.categoryDeleted),
                      action: SnackBarAction(
                        label: l10n.undo,
                        onPressed: () {
                          collection.createEntry(entri);
                        },
                      ),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(collection.errorMessage ??
                          l10n.errorLoadData),
                    ),
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