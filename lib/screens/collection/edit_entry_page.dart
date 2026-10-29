import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_sizes.dart';
import '../../models/collection_entry.dart';
import '../../models/status_collection_enum.dart';
import '../../providers/collection_provider.dart';
import '../../widgets/cover_image.dart';
import '../../widgets/forms/entry_form_fields.dart';

class EditEntryPage extends StatefulWidget {
  final EntriKoleksi entri;

  const EditEntryPage({super.key, required this.entri});

  @override
  State<EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
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
    _status = widget.entri.status;
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

    final progresBaru = int.tryParse(_progresController.text) ?? 0;
    final totalBaru = int.tryParse(_totalController.text);
    final catatanBaru = _catatanController.text.trim().isEmpty
        ? null
        : _catatanController.text.trim();

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
      if (suggest == true) statusUntukSimpan = StatusKoleksi.selesai;
    }

    final entriUpdate = widget.entri.copyWith(
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

    final berhasil = await collection.updateEntry(entriUpdate);
    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.entryUpdated)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
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
              NotificationListener<Notification>(
                onNotification: (_) {
                  if (!_isDirty) setState(() => _isDirty = true);
                  return false;
                },
                child: EntryFormFields(
                  jenisMedia: widget.entri.jenis,
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