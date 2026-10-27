import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/app_sizes.dart';
import '../models/collection_entry.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import '../widgets/cover_image.dart';
import '../widgets/entry_form_fields.dart';

class EditEntryPage extends StatefulWidget {
  final EntriKoleksi entri;

  const EditEntryPage({super.key, required this.entri});

  @override
  State<EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late StatusKoleksi _status;
  late int _progres;
  late TextEditingController _progresController;
  late TextEditingController _totalController;
  late TextEditingController _catatanController;
  int? _rating;

  @override
  void initState() {
    super.initState();
    _status = widget.entri.status;
    _progres = widget.entri.progres;
    _progresController =
        TextEditingController(text: widget.entri.progres.toString());
    _totalController =
        TextEditingController(text: widget.entri.total?.toString() ?? '');
    _catatanController =
        TextEditingController(text: widget.entri.catatan ?? '');
    _rating = widget.entri.rating;
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

    final entriUpdate = widget.entri.copyWith(
      status: _status,
      progres: _progres,
      total: int.tryParse(_totalController.text),
      rating: _rating,
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final berhasil = await collection.updateEntry(entriUpdate);

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryUpdated)),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(collection.errorMessage ?? l10n.errorLoadData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final collection = context.watch<CollectionProvider>();
    final isSaving = collection.isSaving;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.edit)),
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
                  child: CoverImage(url: widget.entri.coverUrl),
                ),
                title: Text(widget.entri.judul),
                subtitle: Text(
                  '${widget.entri.jenis.label(l10n)} • '
                  '${widget.entri.total ?? "?"} '
                  '${widget.entri.jenis.satuanProgres(l10n)}',
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            EntryFormFields(
              jenisMedia: widget.entri.jenis,
              formKey: _formKey,
              status: _status,
              onStatusChanged: (val) => setState(() => _status = val),
              progres: _progres,
              onProgresChanged: (val) => setState(() => _progres = val),
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