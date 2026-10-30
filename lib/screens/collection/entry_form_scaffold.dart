import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_sizes.dart';
import '../../models/collection_entry.dart';
import '../../models/status_collection_enum.dart';
import '../../models/catalog_item.dart';
import '../../providers/collection_provider.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/forms/entry_form_fields.dart';

class EntryFormScaffold extends StatefulWidget {
  final String title;
  final String judul;
  final String? coverUrl;
  final String jenisLabel;
  final String totalLabel;
  final StatusKoleksi initialStatus;
  final int initialProgres;
  final int? initialTotal;
  final int? initialRating;
  final String? initialCatatan;
  final bool isEditing;
  final EntriKoleksi? existingEntry;
  final ItemKatalog? item;

  const EntryFormScaffold({
    super.key,
    required this.title,
    required this.judul,
    this.coverUrl,
    required this.jenisLabel,
    required this.totalLabel,
    required this.initialStatus,
    required this.initialProgres,
    this.initialTotal,
    this.initialRating,
    this.initialCatatan,
    this.isEditing = false,
    this.existingEntry,
    this.item,
  });

  @override
  State<EntryFormScaffold> createState() => _EntryFormScaffoldState();
}

class _EntryFormScaffoldState extends State<EntryFormScaffold> {
  final _formKey = GlobalKey<FormState>();
  late StatusKoleksi _status;
  late TextEditingController _progresController;
  late TextEditingController _totalController;
  late TextEditingController _catatanController;
  int? _rating;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _progresController = TextEditingController(text: widget.initialProgres.toString());
    _totalController = TextEditingController(text: widget.initialTotal?.toString() ?? '');
    _catatanController = TextEditingController(text: widget.initialCatatan ?? '');
    _rating = widget.initialRating;
  }

  @override
  void dispose() {
    _progresController.dispose();
    _totalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final collection = context.read<CollectionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final progresBaru = int.tryParse(_progresController.text) ?? 0;
    final totalBaru = int.tryParse(_totalController.text);
    final catatanBaru = _catatanController.text.trim().isEmpty ? null : _catatanController.text.trim();
    
    var statusUntukSimpan = _status;
    if (totalBaru != null && progresBaru >= totalBaru && _status != StatusKoleksi.selesai) {
      final suggest = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.statusSuggestCompleted),
          content: Text(l10n.statusSuggestCompletedDesc),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.no)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.yes)),
          ],
        ),
      );
      if (!mounted) return;
      if (suggest == true) statusUntukSimpan = StatusKoleksi.selesai;
    }

    bool berhasil;
    if (widget.isEditing && widget.existingEntry != null) {
      // Mode EDIT
      final entriUpdate = widget.existingEntry!.copyWith(
        status: statusUntukSimpan,
        progres: progresBaru,
        total: totalBaru,
        clearTotal: totalBaru == null,
        rating: _rating,
        clearRating: _rating == null,
        catatan: catatanBaru,
        clearCatatan: catatanBaru == null,
        updatedAt: DateTime.now(),
      );
      berhasil = await collection.updateEntry(entriUpdate);
    } else {
      if (collection.hasDuplicateTitle(widget.judul, widget.item!.jenis)) {
        final lanjut = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.inCollection),
            content: Text(l10n.duplicateTitleWarning),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.addAnyway)),
            ],
          ),
        );
        if (!mounted) return;
        if (lanjut != true) return;
      }

      final entriBaru = EntriKoleksi(
        jenis: widget.item!.jenis,
        externalId: 'al:${widget.item!.anilistId}',
        judul: widget.judul,
        coverUrl: widget.coverUrl,
        status: statusUntukSimpan,
        progres: progresBaru,
        total: totalBaru,
        rating: _rating,
        catatan: catatanBaru,
      );
      berhasil = await collection.createEntry(entriBaru);
    }

    if (!mounted) return;

    if (berhasil) {
      messenger.showSnackBar(SnackBar(content: Text(widget.isEditing ? l10n.entryUpdated : l10n.entryAdded)));
      navigator.pop();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(collection.errorMessage ?? l10n.errorLoadData)));
    }
  }

  Future<void> _onWillPop() async {
    if (!_isDirty) {
      Navigator.pop(context);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.keepEditing)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSaving = context.select<CollectionProvider, bool>((c) => c.isSaving);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 60,
                    child: CoverImage(url: widget.coverUrl),
                  ),
                  title: Text(widget.judul),
                  subtitle: Text('${widget.jenisLabel} • ${widget.totalLabel}'),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              EntryFormFields(
                jenisMedia: widget.existingEntry?.jenis ?? widget.item!.jenis,
                formKey: _formKey,
                status: _status,
                onStatusChanged: (val) {
                  setState(() { _status = val; _isDirty = true; });
                },
                progresController: _progresController,
                totalController: _totalController,
                rating: _rating,
                onRatingChanged: (val) {
                  setState(() { _rating = val; _isDirty = true; });
                },
                catatanController: _catatanController,
                isSaving: isSaving,
                onSimpan: _simpan,
                buttonText: l10n.save,
                onDirty: () {
                  if (!_isDirty) setState(() => _isDirty = true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}