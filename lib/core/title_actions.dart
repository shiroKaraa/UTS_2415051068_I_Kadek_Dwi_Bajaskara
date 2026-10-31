import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

Future<void> showTitleActions(
  BuildContext context, {
  required String title,
  VoidCallback? onSearch,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.copy),
            title: Text(l10n.copy),
            onTap: () async {
              Navigator.pop(sheetCtx);
              await Clipboard.setData(ClipboardData(text: title));
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.copiedToClipboard)),
              );
            },
          ),
          if (onSearch != null)
            ListTile(
              leading: const Icon(Icons.search),
              title: Text(l10n.searchNow),
              onTap: () {
                Navigator.pop(sheetCtx);
                onSearch();
              },
            ),
        ],
      ),
    ),
  );
}