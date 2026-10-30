import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/collection_entry.dart';
import 'entry_form_scaffold.dart';

class EditEntryPage extends StatelessWidget {
  final EntriKoleksi entri;

  const EditEntryPage({super.key, required this.entri});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return EntryFormScaffold(
      title: l10n.editEntry,
      judul: entri.judul,
      coverUrl: entri.coverUrl,
      jenisLabel: entri.jenis.label(l10n),
      totalLabel: '${entri.total ?? "?"} ${entri.jenis.satuanProgres(l10n)}',
      initialStatus: entri.status,
      initialProgres: entri.progres,
      initialTotal: entri.total,
      initialRating: entri.rating,
      initialCatatan: entri.catatan,
      existingEntry: entri,
      isEditing: true,
    );
  }
}