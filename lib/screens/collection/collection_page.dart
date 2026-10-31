import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/custom_label.dart';
import '../../models/media_type_enum.dart';
import '../../models/status_collection_enum.dart';
import '../../providers/collection_provider.dart';
import '../../providers/label_provider.dart';
import '../../widgets/skeleton/skeleton_grid_card.dart';
import '../../widgets/skeleton/skeleton_list_card.dart';
import '../../widgets/error_view.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/collection_list_card.dart';
import '../catalog/catalog_page.dart';
import 'collection_detail_page.dart';

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
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

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

  void _enterSelectionMode({int? initialId}) {
    setState(() {
      _isSelectionMode = true;
      if (initialId != null) _selectedIds.add(initialId);
    });
    HapticFeedback.selectionClick();
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _selectAll(CollectionProvider collection) {
    setState(() {
      _selectedIds.addAll(
        collection.entries.map((e) => e.id).whereType<int>(),
      );
    });
  }

  void _showSortSheet(BuildContext context, AppLocalizations l10n) {
    final collection = context.read<CollectionProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  l10n.sortPickOrder,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              RadioGroup<UrutanKoleksi>(
                groupValue: collection.urutan,
                onChanged: (v) {
                  if (v != null) collection.setUrutan(v);
                  Navigator.pop(sheetCtx);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: UrutanKoleksi.values.map((u) {
                    return RadioListTile<UrutanKoleksi>(
                      value: u,
                      title: Text(_labelForUrutan(u, l10n)),
                    );
                  }).toList(),
                ),
              ),
              // ▲ UBAH ▲
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  l10n.sortDirection,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              RadioGroup<bool>(
                groupValue: collection.urutanAsc,
                onChanged: (v) {
                  if (v != null) {
                    collection.setUrutanDirection(v);
                    Navigator.pop(sheetCtx);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<bool>(
                      value: true,
                      title: Row(
                        children: [
                          const Icon(Icons.arrow_upward, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.sortAscending),
                        ],
                      ),
                    ),
                    RadioListTile<bool>(
                      value: false,
                      title: Row(
                        children: [
                          const Icon(Icons.arrow_downward, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.sortDescending),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _labelForUrutan(UrutanKoleksi u, AppLocalizations l10n) {
    switch (u) {
      case UrutanKoleksi.terbaru:
        return l10n.sortNewest;
      case UrutanKoleksi.ditambahkan:
        return l10n.sortAddedDate;
      case UrutanKoleksi.judul:
        return l10n.sortTitle;
      case UrutanKoleksi.progres:
        return l10n.sortProgress;
      case UrutanKoleksi.rating:
        return l10n.sortRating;
    }
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

  Future<void> _deleteSelected(AppLocalizations l10n) async {
    final collection = context.read<CollectionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final count = _selectedIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.confirmDeleteMultiple(count)),
        content: Text(l10n.confirmDeleteMultipleDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final deleted = await collection.deleteMany(Set.from(_selectedIds));
    if (!mounted) return;

    if (deleted > 0) {
      _exitSelectionMode();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bulkDeleted(deleted))),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(collection.errorMessage ?? l10n.errorLoadData),
        ),
      );
    }
  }

  Future<void> _changeLabelSelected(AppLocalizations l10n) async {
    final collection = context.read<CollectionProvider>();
    final labels = context.read<LabelProvider>().labels;
    final messenger = ScaffoldMessenger.of(context);

    final selected = await showModalBottomSheet<Object?>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                l10n.changeLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.label_off_outlined),
              title: Text(l10n.noLabel),
              onTap: () => Navigator.pop(sheetCtx, 'none'),
            ),
            ...labels.map(
              (LabelKustom lbl) => ListTile(
                leading: const Icon(Icons.label_outline,
                    color: AppColors.infoBlue),
                title: Text(lbl.nama),
                onTap: () => Navigator.pop(sheetCtx, lbl.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    if (!mounted) return;

    final int? labelId = selected == 'none' ? null : selected as int?;
    final updated =
        await collection.updateManyLabel(Set.from(_selectedIds), labelId);
    if (!mounted) return;

    if (updated > 0) {
      _exitSelectionMode();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bulkUpdated(updated))),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(collection.errorMessage ?? l10n.errorLoadData),
        ),
      );
    }
  }

  Future<void> _changeStatusSelected(AppLocalizations l10n) async {
    final collection = context.read<CollectionProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final selected = await showModalBottomSheet<StatusKoleksi>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                l10n.changeStatus,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...StatusKoleksi.values.map(
              (s) => ListTile(
                leading: Icon(Icons.flag_outlined,
                    color: AppColors.primaryGreen),
                title: Text(s.netralLabel(l10n)),
                onTap: () => Navigator.pop(sheetCtx, s),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    if (!mounted) return;

    final updated =
        await collection.updateManyStatus(Set.from(_selectedIds), selected);
    if (!mounted) return;

    if (updated > 0) {
      _exitSelectionMode();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.bulkUpdated(updated))),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(collection.errorMessage ?? l10n.errorLoadData),
        ),
      );
    }
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

    final validIds = collection.allEntries.map((e) => e.id).toSet();
    if (_selectedIds.isNotEmpty) {
      final stale = _selectedIds.difference(validIds.cast<int>());
      if (stale.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selectedIds.removeAll(stale);
            if (_selectedIds.isEmpty) _isSelectionMode = false;
          });
        });
      }
    }

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isSelectionMode) _exitSelectionMode();
      },
      child: Scaffold(
        appBar: _isSelectionMode
            ? _buildSelectionAppBar(l10n, collection)
            : _buildNormalAppBar(l10n, collection),
        body: _isSelectionMode
            ? _buildContent(context, collection, l10n)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.spacingM,
                        AppSizes.spacingS, AppSizes.spacingM, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _debounceTimer?.cancel();
                        _debounceTimer =
                            Timer(const Duration(milliseconds: 300), () {
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
                        suffixIcon:
                            ValueListenableBuilder<TextEditingValue>(
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
                        horizontal: AppSizes.spacingM,
                        vertical: AppSizes.spacingS),
                    child: Row(
                      children: [
                        _buildStatusChip(
                            context, l10n.all, null, collection),
                        ...StatusKoleksi.values.map((status) =>
                            _buildStatusChip(context,
                                status.netralLabel(l10n), status, collection)),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
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
                              final messenger =
                                  ScaffoldMessenger.of(context);
                              final ok =
                                  await collection.retryConnection();
                              if (!context.mounted) return;
                              messenger.showSnackBar(SnackBar(
                                content: Text(ok
                                    ? l10n.reconnected
                                    : l10n.stillOffline),
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
        bottomNavigationBar:
            _isSelectionMode ? _buildSelectionBottomBar(l10n) : null,
      ),
    );
  }

  AppBar _buildNormalAppBar(
      AppLocalizations l10n, CollectionProvider collection) {
    return AppBar(
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
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: l10n.sortBy,
          onPressed: () => _showSortSheet(context, l10n),
        ),
        IconButton(
          icon: const Icon(Icons.checklist),
          tooltip: l10n.selectItems,
          onPressed: () => _enterSelectionMode(),
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar(
      AppLocalizations l10n, CollectionProvider collection) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
      ),
      title: Text(l10n.selectedCount(_selectedIds.length)),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: l10n.selectAll,
          onPressed: () => _selectAll(collection),
        ),
      ],
    );
  }

  Widget _buildSelectionBottomBar(AppLocalizations l10n) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _selectionAction(
                icon: Icons.delete_outline,
                label: l10n.delete,
                color: Colors.redAccent,
                onTap: _selectedIds.isEmpty
                    ? null
                    : () => _deleteSelected(l10n),
              ),
            ),
            Expanded(
              child: _selectionAction(
                icon: Icons.label_outline,
                label: l10n.changeLabel,
                color: AppColors.infoBlue,
                onTap: _selectedIds.isEmpty
                    ? null
                    : () => _changeLabelSelected(l10n),
              ),
            ),
            Expanded(
              child: _selectionAction(
                icon: Icons.flag_outlined,
                label: l10n.changeStatus,
                color: AppColors.primaryGreen,
                onTap: _selectedIds.isEmpty
                    ? null
                    : () => _changeStatusSelected(l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: disabled ? Colors.grey : color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: disabled ? Colors.grey : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
          mainAxisExtent: 180 * 1.5 +
              (72 * MediaQuery.textScalerOf(context).scale(1.0)),
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
        mainAxisExtent: 180 * 1.5 +
            (72 * MediaQuery.textScalerOf(context).scale(1.0)),
      ),
      itemCount: collection.entries.length,
      itemBuilder: (context, index) {
        final entri = collection.entries[index];
        final id = entri.id!;
        final isSelected = _selectedIds.contains(id);
        return CollectionCard(
          key: ValueKey(entri.id),
          entri: entri,
          isSelectionMode: _isSelectionMode,
          isSelected: isSelected,
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(id);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CollectionDetailPage(id: entri.id!),
                ),
              );
            }
          },
          onLongPress: () {
            if (_isSelectionMode) {
              _toggleSelection(id);
            } else {
              _enterSelectionMode(initialId: id);
            }
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
        final id = entri.id!;
        final isProcessing = _processingIds.contains(entri.id);
        final isSelected = _selectedIds.contains(id);

        return CollectionListCard(
          key: ValueKey(entri.id),
          entri: entri,
          isProcessing: isProcessing,
          isSelectionMode: _isSelectionMode,
          isSelected: isSelected,
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(id);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CollectionDetailPage(id: entri.id!),
                ),
              );
            }
          },
          onLongPress: () {
            if (_isSelectionMode) {
              _toggleSelection(id);
            } else {
              _enterSelectionMode(initialId: id);
            }
          },
          onIncrement: () async {
            if (_isSelectionMode) return;
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
}