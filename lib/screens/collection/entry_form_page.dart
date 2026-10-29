import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_sizes.dart';
import '../../models/catalog_item.dart';
import '../../models/collection_entry.dart';
import '../../models/status_collection_enum.dart';
import '../../providers/collection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/forms/entry_form_fields.dart';

class EntryFormPage extends StatefulWidget {
  final ItemKatalog item;

  const EntryFormPage({super.key, required this.item});

  @override
  State<EntryFormPage> createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
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
    _status = StatusKoleksi.direncanakan;
    _progresController = TextEditingController(text: '0');
    _totalController =
        TextEditingController(text: widget.item.total?.toString() ?? '');
    _catatanController = TextEditingController();
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
    final settings = context.read<SettingsProvider>();
    final collection = context.read<CollectionProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final progresBaru = int.tryParse(_progresController.text) ?? 0;
    final totalBaru = int.tryParse(_totalController.text);
    final judul = widget.item.displayTitle;

    // B-23: auto-suggest status Selesai.
    var statusUntukSimpan = _status;
    if (totalBaru != null &&
        progresBaru >= totalBaru &&
        _status != StatusKoleksi.selesai) {
      final suggest = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.statusSuggestCompleted),
          content: Text(l10n.statusSuggestCompletedDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.no),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.yes),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (suggest == true) {
        statusUntukSimpan = StatusKoleksi.selesai;
      }
    }

    if (collection.hasDuplicateTitle(judul, widget.item.jenis)) {
      final lanjut = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.inCollection),
          content: Text(l10n.duplicateTitleWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.addAnyway),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (lanjut != true) return;
    }

    final entriBaru = EntriKoleksi(
      deviceId: settings.deviceId,
      jenis: widget.item.jenis,
      externalId: 'al:${widget.item.anilistId}',
      judul: judul,
      coverUrl: widget.item.coverUrl,
      status: statusUntukSimpan,
      progres: progresBaru,
      total: totalBaru,
      rating: _rating,
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
    );

    final berhasil = await collection.createEntry(entriBaru);
    if (!mounted) return;

    if (berhasil) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.entryAdded)),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(collection.errorMessage ?? l10n.errorLoadData)),
      );
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.keepEditing),
          ),
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
    final isSaving =
        context.select<CollectionProvider, bool>((c) => c.isSaving);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.addToCollection)),
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
                    child: CoverImage(url: widget.item.coverUrl),
                  ),
                  title: Text(widget.item.displayTitle),
                  subtitle: Text(
                    '${widget.item.jenis.label(l10n)} • '
                    '${widget.item.total ?? "?"} '
                    '${widget.item.jenis.satuanProgres(l10n)}',
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              NotificationListener<Notification>(
                onNotification: (_) {
                  if (!_isDirty) setState(() => _isDirty = true);
                  return false;
                },
                child: EntryFormFields(
                  jenisMedia: widget.item.jenis,
                  formKey: _formKey,
                  status: _status,
                  onStatusChanged: (val) => setState(() {
                    _status = val;
                    _isDirty = true;
                  }),
                  progresController: _progresController,
                  totalController: _totalController,
                  rating: _rating,
                  onRatingChanged: (val) => setState(() {
                    _rating = val;
                    _isDirty = true;
                  }),
                  catatanController: _catatanController,
                  isSaving: isSaving,
                  onSimpan: _simpan,
                  buttonText: l10n.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}