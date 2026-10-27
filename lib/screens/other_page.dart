import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import '../providers/settings_provider.dart';
import 'about_page.dart';
import 'category_page.dart';
import 'help_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';
import 'storage_page.dart';

class OtherPage extends StatefulWidget {
  const OtherPage({super.key});

  @override
  State<OtherPage> createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final collection = context.watch<CollectionProvider>();

    final total = collection.allEntries.length;
    final sedang = collection.allEntries
        .where((e) => e.status == StatusKoleksi.sedang)
        .length;
    final selesai = collection.allEntries
        .where((e) => e.status == StatusKoleksi.selesai)
        .length;

    final localeLabel = settings.locale.languageCode == 'id'
        ? 'Indonesia'
        : 'English';
    final themeLabel = settings.themeMode == ThemeMode.dark
        ? l10n.dark
        : settings.themeMode == ThemeMode.light
            ? l10n.light
            : l10n.system;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, l10n, theme),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingXl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _AnimatedEntry(
                  delayMs: 0,
                  child: _SectionTitle(
                    title: l10n.activityDetails,
                    icon: Icons.insights_outlined,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                _AnimatedEntry(
                  delayMs: 60,
                  child: _buildActivityStats(
                      context, l10n, total, sedang, selesai),
                ),
                const SizedBox(height: AppSizes.spacingL),
                _AnimatedEntry(
                  delayMs: 120,
                  child: _SectionTitle(
                    title: l10n.manageCategories,
                    icon: Icons.tune_rounded,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                _AnimatedEntry(
                  delayMs: 180,
                  child: _buildManageGrid(context, l10n),
                ),
                const SizedBox(height: AppSizes.spacingL),
                _AnimatedEntry(
                  delayMs: 240,
                  child: _SectionTitle(
                    title: l10n.settings,
                    icon: Icons.settings_outlined,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                _AnimatedEntry(
                  delayMs: 300,
                  child: _buildSettingsTile(
                    context,
                    l10n,
                    themeLabel: themeLabel,
                    localeLabel: localeLabel,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingL),
                _AnimatedEntry(
                  delayMs: 360,
                  child: _SectionTitle(
                    title: l10n.help,
                    icon: Icons.info_outline,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                _AnimatedEntry(
                  delayMs: 420,
                  child: _buildOthersList(context, l10n),
                ),
                const SizedBox(height: AppSizes.spacingXl),
                _AnimatedEntry(
                  delayMs: 480,
                  child: _buildFooter(context, l10n),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SliverAppBar(
      pinned: false,
      floating: false,
      expandedHeight: 200,
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      foregroundColor:
          isDark ? AppColors.textLight : AppColors.textDark,
      title: Text(l10n.navOther),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkCard,
                      AppColors.primaryGreen.withValues(alpha: 0.25),
                    ]
                  : [
                      AppColors.lightCard,
                      AppColors.primaryGreenDark.withValues(alpha: 0.18),
                    ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.spacingL,
                56,
                AppSizes.spacingL,
                AppSizes.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen
                                .withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: AppColors.primaryGreen,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tsuzuki',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              l10n.appDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme
                                    .colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityStats(
    BuildContext context,
    AppLocalizations l10n,
    int total,
    int sedang,
    int selesai,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.collections_bookmark,
            label: l10n.statTotal,
            value: total.toString(),
            color: AppColors.infoBlue,
            onTap: () => _go(context, const StatisticsPage()),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: _StatCard(
            icon: Icons.play_circle_outline,
            label: l10n.statReading,
            value: sedang.toString(),
            color: AppColors.primaryGreen,
            onTap: () => _go(context, const StatisticsPage()),
          ),
        ),
        const SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            label: l10n.statCompleted,
            value: selesai.toString(),
            color: AppColors.goldPrimary,
            onTap: () => _go(context, const StatisticsPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildManageGrid(
      BuildContext context, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        final spacing = AppSizes.spacingS;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: width,
              child: _MenuTile(
                icon: Icons.insights_outlined,
                label: l10n.statistics,
                color: AppColors.infoBlue,
                onTap: () => _go(context, const StatisticsPage()),
              ),
            ),
            SizedBox(
              width: width,
              child: _MenuTile(
                icon: Icons.label_outline,
                label: l10n.manageCategories,
                color: AppColors.primaryGreen,
                onTap: () => _go(context, const CategoryPage()),
              ),
            ),
            SizedBox(
              width: width,
              child: _MenuTile(
                icon: Icons.storage_outlined,
                label: l10n.storage,
                color: AppColors.goldPrimary,
                onTap: () => _go(context, const StoragePage()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    AppLocalizations l10n, {
    required String themeLabel,
    required String localeLabel,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: () => _go(context, const SettingsPage()),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Row(
            children: [
              _CircleIcon(
                icon: Icons.settings_outlined,
                color: AppColors.typeManhua,
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settings,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppSizes.spacingXs,
                      runSpacing: AppSizes.spacingXs,
                      children: [
                        _MiniChip(
                          icon: Icons.palette_outlined,
                          label: themeLabel,
                        ),
                        _MiniChip(
                          icon: Icons.language,
                          label: localeLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOthersList(
      BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    Widget tile({
      required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
        child: Card(
          elevation: 0,
          color: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            side: BorderSide(
              color:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            leading: _CircleIcon(icon: icon, color: color),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: onTap,
          ),
        ),
      );
    }

    return Column(
      children: [
        tile(
          icon: Icons.favorite_border,
          title: l10n.supportUs,
          color: AppColors.typeManga,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.supportThankYou)),
            );
          },
        ),
        tile(
          icon: Icons.help_outline,
          title: l10n.helpFaq,
          color: AppColors.infoBlue,
          onTap: () => _go(context, const HelpPage()),
        ),
        tile(
          icon: Icons.info_outline,
          title: l10n.aboutApp,
          color: AppColors.primaryGreen,
          onTap: () => _go(context, const AboutPage()),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.auto_stories,
          size: 28,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        const SizedBox(height: AppSizes.spacingXs),
        Text(
          '${l10n.copyright} • v1.0.0',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: AppSizes.spacingS),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.spacingM,
            horizontal: AppSizes.spacingS,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CircleIcon(icon: icon, color: color),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CircleIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEntry extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const _AnimatedEntry({required this.child, this.delayMs = 0});

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}