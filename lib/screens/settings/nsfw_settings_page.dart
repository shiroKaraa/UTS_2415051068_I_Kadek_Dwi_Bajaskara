import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_sizes.dart';
import '../../l10n/app_localizations.dart';
import '../../models/nsfw_settings.dart';
import '../../providers/settings_provider.dart';

class NsfwSettingsPage extends StatefulWidget {
  const NsfwSettingsPage({super.key});

  @override
  State<NsfwSettingsPage> createState() => _NsfwSettingsPageState();
}

class _NsfwSettingsPageState extends State<NsfwSettingsPage> {
  Future<void> _toggleMaster(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<SettingsProvider>();

    if (value && !settings.enableNsfw) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          title: Text(l10n.nsfwEnableTitle),
          content: Text(l10n.nsfwEnableBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: Text(l10n.yes),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (!mounted) return;
    await settings.setEnableNsfw(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final nsfw = settings.nsfw;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nsfwSettingsTitle)),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(AppSizes.spacingM),
            elevation: 0,
            color: nsfw.enabled
                ? Colors.redAccent.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              side: BorderSide(
                color: nsfw.enabled
                    ? Colors.redAccent.withValues(alpha: 0.4)
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: SwitchListTile(
              secondary: Icon(
                nsfw.enabled
                    ? Icons.visibility
                    : Icons.visibility_off_outlined,
                color: nsfw.enabled ? Colors.redAccent : null,
              ),
              title: Text(
                l10n.nsfwSettingsTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l10n.nsfwSettingsSubtitle),
              value: nsfw.enabled,
              onChanged: _toggleMaster,
            ),
          ),
          if (nsfw.enabled) ...[
            _SectionHeader(
                title: l10n.nsfwSectionSensor, icon: Icons.blur_on),
            SwitchListTile(
              secondary: const Icon(Icons.image_outlined),
              title: Text(l10n.nsfwBlurCovers),
              subtitle: Text(l10n.nsfwBlurCoversDesc),
              value: nsfw.blurCovers,
              onChanged: settings.setNsfwBlurCovers,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.title),
              title: Text(l10n.nsfwBlurTitles),
              subtitle: Text(l10n.nsfwBlurTitlesDesc),
              value: nsfw.blurTitles,
              onChanged: settings.setNsfwBlurTitles,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.visibility_off_outlined),
              title: Text(l10n.nsfwHideBadge),
              subtitle: Text(l10n.nsfwHideBadgeDesc),
              value: nsfw.hideBadge,
              onChanged: settings.setNsfwHideBadge,
            ),
            const Divider(),
            _SectionHeader(
                title: l10n.nsfwSectionLevel, icon: Icons.tune),
            RadioGroup<NsfwFilterLevel>(
              groupValue: nsfw.filterLevel,
              onChanged: (v) {
                if (v != null) settings.setNsfwFilterLevel(v);
              },
              child: Column(
                children: [
                  RadioListTile<NsfwFilterLevel>(
                    value: NsfwFilterLevel.off,
                    title: Text(l10n.nsfwLevelOff),
                    subtitle: Text(l10n.nsfwLevelOffDesc),
                  ),
                  RadioListTile<NsfwFilterLevel>(
                    value: NsfwFilterLevel.light,
                    title: Text(l10n.nsfwLevelLight),
                    subtitle: Text(l10n.nsfwLevelLightDesc),
                  ),
                  RadioListTile<NsfwFilterLevel>(
                    value: NsfwFilterLevel.heavy,
                    title: Text(l10n.nsfwLevelHeavy),
                    subtitle: Text(l10n.nsfwLevelHeavyDesc),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.nsfwInfoNote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingM, AppSizes.spacingM, AppSizes.spacingM, 4),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}