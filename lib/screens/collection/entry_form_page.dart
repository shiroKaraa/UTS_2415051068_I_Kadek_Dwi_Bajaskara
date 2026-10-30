import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/catalog_item.dart';
import '../../models/status_collection_enum.dart';
import 'entry_form_scaffold.dart';

class EntryFormPage extends StatelessWidget {
  final ItemKatalog item;

  const EntryFormPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return EntryFormScaffold(
      title: l10n.addToCollection,
      judul: item.displayTitle,
      coverUrl: item.coverUrl,
      jenisLabel: item.jenis.label(l10n),
      totalLabel: '${item.total ?? "?"} ${item.jenis.satuanProgres(l10n)}',
      initialStatus: StatusKoleksi.direncanakan,
      initialProgres: 0,
      initialTotal: item.total,
      item: item,
      isEditing: false,
    );
  }
}