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

    final progresBaru = int.tryParse(_progresController.text) ?? 0;

    final entriBaru = EntriKoleksi(
      deviceId: settings.deviceId,
      jenis: widget.item.jenis,
      externalId: 'al:${widget.item.anilistId}',
      judul: widget.item.displayTitle,
      coverUrl: widget.item.coverUrl,
      status: _status,
      progres: progresBaru,
      total: int.tryParse(_totalController.text),
      rating: _rating,
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
    );

    final berhasil = await collection.createEntry(entriBaru);
    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addToCollection)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(collection.errorMessage ?? l10n.errorLoadData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSaving =
        context.select<CollectionProvider, bool>((c) => c.isSaving);

    return Scaffold(
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
            EntryFormFields(
              jenisMedia: widget.item.jenis,
              formKey: _formKey,
              status: _status,
              onStatusChanged: (val) => setState(() => _status = val),
              progresController: _progresController,
              totalController: _totalController,
              rating: _rating,
              onRatingChanged: (val) => setState(() => _rating = val),
              catatanController: _catatanController,
              isSaving: isSaving,
              onSimpan: _simpan,
              buttonText: l10n.save,
            ),
          ],
        ),
      ),
    );
  }
}