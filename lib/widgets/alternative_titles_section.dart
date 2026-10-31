import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_sizes.dart';
import '../l10n/app_localizations.dart';
import '../models/catalog_item.dart';

class AlternativeTitlesSection extends StatelessWidget {
  final ItemKatalog item;

  const AlternativeTitlesSection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titles = item.alternativeTitles;

    if (titles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.alternativeTitles,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Column(
            children: [
              for (int i = 0; i < titles.length; i++) ...[
                ListTile(
                  dense: true,
                  title: Text(
                    titles[i].key,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  subtitle: Text(titles[i].value),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: l10n.copy,
                    onPressed: () async {
                      await Clipboard.setData(
                          ClipboardData(text: titles[i].value));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.copiedToClipboard)),
                      );
                    },
                  ),
                ),
                if (i < titles.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}