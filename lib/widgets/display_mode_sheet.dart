import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_sizes.dart';
import '../l10n/app_localizations.dart';
import '../models/card_size_enum.dart';
import '../providers/settings_provider.dart';

class DisplayModeSheet extends StatefulWidget {
  const DisplayModeSheet({super.key});

  @override
  State<DisplayModeSheet> createState() => _DisplayModeSheetState();
}

class _DisplayModeSheetState extends State<DisplayModeSheet> {
  late int _tempItemsPerRow;
  late bool _tempListView;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _tempItemsPerRow = s.itemsPerRow;
    _tempListView = s.isListView;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.displayMode,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              l10n.displayMode,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Wrap(
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingS,
              children: [
                _modeButton(
                  context: context,
                  label: l10n.displayGrid,
                  isSelected: !_tempListView,
                  onTap: () {
                    setState(() => _tempListView = false);
                    context.read<SettingsProvider>().setListView(false);
                  },
                ),
                _modeButton(
                  context: context,
                  label: l10n.displayList,
                  isSelected: _tempListView,
                  onTap: () {
                    setState(() => _tempListView = true);
                    context.read<SettingsProvider>().setListView(true);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              l10n.displayCardSize,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.spacingS),
            Wrap(
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingS,
              children: [
                _sizeButton(
                  context: context,
                  label: l10n.cardSizeSmall,
                  size: CardSize.small,
                  currentSize: settings.cardSize,
                ),
                _sizeButton(
                  context: context,
                  label: l10n.cardSizeMedium,
                  size: CardSize.medium,
                  currentSize: settings.cardSize,
                ),
                _sizeButton(
                  context: context,
                  label: l10n.cardSizeLarge,
                  size: CardSize.large,
                  currentSize: settings.cardSize,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.itemsPerRow,
                  style: theme.textTheme.titleSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_tempItemsPerRow',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Slider(
              value: _tempItemsPerRow.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              label: '$_tempItemsPerRow',
              onChanged: (v) {
                setState(() => _tempItemsPerRow = v.round());
                context.read<SettingsProvider>().setItemsPerRow(v.round());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : null,
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
    );
  }

  Widget _sizeButton({
    required BuildContext context,
    required String label,
    required CardSize size,
    required CardSize currentSize,
  }) {
    return _modeButton(
      context: context,
      label: label,
      isSelected: currentSize == size,
      onTap: () => context.read<SettingsProvider>().setCardSize(size),
    );
  }
}