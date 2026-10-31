import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/collection_entry.dart';
import '../../models/media_type_enum.dart';
import '../../models/status_collection_enum.dart';
import '../../providers/collection_provider.dart';
import '../../widgets/skeleton/skeleton_grid_card.dart';
import '../../widgets/skeleton/skeleton_list_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/collection_list_card.dart';
import '../catalog/catalog_page.dart';
import 'collection_detail_page.dart';
import 'edit_entry_page.dart';

class CollectionPage extends StatefulWidget {
  final StatusKoleksi? initialStatus;

  const CollectionPage({super.key, this.initialStatus});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _lastQuery = '';
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CollectionProvider>();
      if (provider.filterStatus != widget.initialStatus) {
        provider.setFilterStatus(widget.initialStatus);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
    final collection = context.read<CollectionProvider>();
    JenisMedia? tempJenis = collection.filterJenis;
    int? tempRating = collection.filterRating;
    StatusKoleksi? tempStatus = collection.filterStatus;
    bool tempFavorit = collection.filterFavorit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.spacingM),
                  children: [
                    Text(l10n.activeFilter,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.spacingM),
                    DropdownButtonFormField<JenisMedia>(
                      initialValue: tempJenis,
                      decoration: InputDecoration(
                          labelText: l10n.filterType,
                          border: const OutlineInputBorder(),
                          isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.all)),
                        ...JenisMedia.values.map((j) => DropdownMenuItem(
                            value: j, child: Text(j.label(l10n)))),
                      ],
                      onChanged: (val) => setState(() => tempJenis = val),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    DropdownButtonFormField<int>(
                      initialValue: tempRating,
                      decoration: const InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(),
                          isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.all)),
                        ...List.generate(5, (i) => i + 1).map((val) =>
                            DropdownMenuItem(
                                value: val, child: Text('⭐' * val))),
                      ],
                      onChanged: (val) => setState(() => tempRating = val),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    DropdownButtonFormField<StatusKoleksi>(
                      initialValue: tempStatus,
                      decoration: InputDecoration(
                          labelText: l10n.filterStatus,
                          border: const OutlineInputBorder(),
                          isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.all)),
                        ...StatusKoleksi.values.map((s) => DropdownMenuItem(
                            value: s, child: Text(s.netralLabel(l10n)))),
                      ],
                      onChanged: (val) => setState(() => tempStatus = val),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    SwitchListTile(
                      title: Text(l10n.onlyFavorites),
                      secondary: const Icon(Icons.favorite,
                          color: Colors.redAccent),
                      value: tempFavorit,
                      onChanged: (val) => setState(() => tempFavorit = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              collection.clearFilters();
                              Navigator.pop(sheetCtx);
                            },
                            child: Text(l10n.reset),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              collection.setFilters(
                                  jenis: tempJenis,
                                  rating: tempRating,
                                  status: tempStatus);
                              collection.setFilterFavorit(tempFavorit);
                              Navigator.pop(sheetCtx);
                            },
                            child: Text(l10n.apply),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
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

    if (collection.query != _lastQuery) {
      _lastQuery = collection.query;
      if (_searchController.text.trim() != collection.query) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final q = collection.query;
          _searchController.value = TextEditingValue(
            text: q,
            selection: TextSelection.collapsed(offset: q.length),
          );
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCollection),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list),
                if (collection.hasActiveFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: l10n.activeFilter,
            onPressed: () => _showFilterSheet(context, l10n),
          ),
          IconButton(
            icon: Icon(
                collection.isListView ? Icons.grid_view : Icons.view_list),
            tooltip: collection.isListView ? l10n.gridView : l10n.listView,
            onPressed: () => collection.toggleView(),
          ),
          PopupMenuButton<UrutanKoleksi>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortBy,
            onSelected: (value) => collection.setUrutan(value),
            itemBuilder: (context) => [
              _buildSortItem(l10n.sortNewest, UrutanKoleksi.terbaru,
                  collection.urutan),
              _buildSortItem(
                  l10n.sortTitle, UrutanKoleksi.judul, collection.urutan),
              _buildSortItem(l10n.sortProgress, UrutanKoleksi.progres,
                  collection.urutan),
              _buildSortItem(
                  l10n.sortRating, UrutanKoleksi.rating, collection.urutan),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.spacingM, AppSizes.spacingS, AppSizes.spacingM, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                  if (mounted) collection.setQuery(val.trim());
                });
              },
              onSubmitted: (val) {
                _debounceTimer?.cancel();
                collection.setQuery(val.trim());
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchInCollection,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _debounceTimer?.cancel();
                              _searchController.clear();
                              collection.setQuery('');
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM, vertical: AppSizes.spacingS),
            child: Row(
              children: [
                _buildStatusChip(context, l10n.all, null, collection),
                ...StatusKoleksi.values.map((status) => _buildStatusChip(
                    context, status.netralLabel(l10n), status, collection)),
              ],
            ),
          ),
          if (!collection.isLoading &&
              collection.errorMessage == null &&
              collection.entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingM),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${collection.entries.length} ${l10n.trackedTitles('').trim()}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
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
                  Expanded(
                    child: Text(l10n.offlineBanner,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await collection.retryConnection();
                      if (!context.mounted) return;
                      messenger.showSnackBar(SnackBar(
                        content:
                            Text(ok ? l10n.reconnected : l10n.stillOffline),
                      ));
                    },
                    child: Text(l10n.retryConnection,
                        style: const TextStyle(fontSize: 12)),
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

  Widget _buildStatusChip(BuildContext context, String label,
      StatusKoleksi? status, CollectionProvider collection) {
    final isSelected = collection.filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) collection.setFilterStatus(status);
        },
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
          padding: const EdgeInsets.all(AppSizes.spacingM),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) => const SkeletonListCard(),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 180 * 1.5 + (72 * MediaQuery.textScalerOf(context).scale(1.0)),
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const SkeletonGridCard(),
      );
    }

    if (collection.errorMessage != null && collection.allEntries.isEmpty) {
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
        actionLabel: isFiltered ? l10n.resetFilter : l10n.searchNow,
        onAction: isFiltered
            ? () => collection.clearFilters()
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogPage()),
                );
              },
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
      padding: const EdgeInsets.all(AppSizes.spacingM),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 180 * 1.5 + (72 * MediaQuery.textScalerOf(context).scale(1.0)),
      ),
      itemCount: collection.entries.length,
      itemBuilder: (context, index) {
        final entri = collection.entries[index];
        return CollectionCard(
          key: ValueKey(entri.id),
          entri: entri,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailPage(id: entri.id!),
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
      padding: const EdgeInsets.all(AppSizes.spacingM),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: collection.entries.length,
      itemBuilder: (context, index) {
        final entri = collection.entries[index];
        final isProcessing = _processingIds.contains(entri.id);

        return CollectionListCard(
          key: ValueKey(entri.id),
          entri: entri,
          isProcessing: isProcessing,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailPage(id: entri.id!),
              ),
            );
          },
          onLongPress: () => _showQuickMenu(context, entri),
          onIncrement: () async {
            setState(() => _processingIds.add(entri.id!));
            final provider = context.read<CollectionProvider>();
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();

            final result = await provider.incrementProgress(entri);
            if (!context.mounted) return;
            setState(() => _processingIds.remove(entri.id));

            if (result == HasilIncrement.inFlight) return;
            if (result == HasilIncrement.ok) {
              messenger.showSnackBar(
                  SnackBar(content: Text(l10n.progressAdded)));
            } else if (result == HasilIncrement.offline) {
              messenger.showSnackBar(
                  SnackBar(content: Text(l10n.offlineMode)));
            } else if (result == HasilIncrement.alreadyCompleted) {
              messenger.showSnackBar(
                  SnackBar(content: Text(l10n.congratsCompleted)));
            } else {
              messenger.showSnackBar(SnackBar(
                  content:
                      Text(provider.errorMessage ?? l10n.errorLoadData)));
            }
          },
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
                    content: Text('${l10n.delete} "${entri.judul}"?'),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogCtx, false),
                          child: Text(l10n.cancel)),
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
                if (!context.mounted) return;
                final berhasil = await collection.deleteEntry(entri);
                if (!berhasil) {
                  messenger.showSnackBar(
                    SnackBar(
                        content: Text(collection.errorMessage ??
                            l10n.errorLoadData)),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}