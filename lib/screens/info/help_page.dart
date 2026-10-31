import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_sizes.dart';

class _FaqItem {
  final String title;
  final String desc;
  const _FaqItem(this.title, this.desc);
}

class _FaqCategory {
  final String title;
  final IconData icon;
  final List<_FaqItem> items;
  const _FaqCategory(this.title, this.icon, this.items);
}

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqCategory> _buildCategories(AppLocalizations l10n) {
    return [
      _FaqCategory(
        l10n.helpCatGettingStarted,
        Icons.rocket_launch_outlined,
        [
          _FaqItem(l10n.faq1Title, l10n.faq1Desc),
          _FaqItem(l10n.faq16Title, l10n.faq16Desc),
          _FaqItem(l10n.faq17Title, l10n.faq17Desc),
        ],
      ),
      _FaqCategory(
        l10n.helpCatCatalog,
        Icons.explore_outlined,
        [
          _FaqItem(l10n.faq12Title, l10n.faq12Desc),
          _FaqItem(l10n.faq7Title, l10n.faq7Desc),
          _FaqItem(l10n.faq11Title, l10n.faq11Desc),
        ],
      ),
      _FaqCategory(
        l10n.helpCatCollection,
        Icons.collections_bookmark_outlined,
        [
          _FaqItem(l10n.faq2Title, l10n.faq2Desc),
          _FaqItem(l10n.faq15Title, l10n.faq15Desc),
          _FaqItem(l10n.faq6Title, l10n.faq6Desc),
          _FaqItem(l10n.faq13Title, l10n.faq13Desc),
          _FaqItem(l10n.faq14Title, l10n.faq14Desc),
        ],
      ),
      _FaqCategory(
        l10n.helpCatSettings,
        Icons.settings_outlined,
        [
          _FaqItem(l10n.faq5Title, l10n.faq5Desc),
          _FaqItem(l10n.faq4Title, l10n.faq4Desc),
        ],
      ),
      _FaqCategory(
        l10n.helpCatData,
        Icons.storage_outlined,
        [
          _FaqItem(l10n.faq8Title, l10n.faq8Desc),
          _FaqItem(l10n.faq9Title, l10n.faq9Desc),
        ],
      ),
      _FaqCategory(
        l10n.helpCatTroubleshooting,
        Icons.bug_report_outlined,
        [
          _FaqItem(l10n.faq3Title, l10n.faq3Desc),
          _FaqItem(l10n.faq10Title, l10n.faq10Desc),
          _FaqItem(l10n.passwordRecoveryFaqTitle, l10n.passwordRecoveryFaqDesc),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categories = _buildCategories(l10n);
    final q = _query.toLowerCase().trim();
    final filteredCategories = q.isEmpty
        ? categories
        : categories
            .map((cat) {
              final matched = cat.items
                  .where((it) =>
                      it.title.toLowerCase().contains(q) ||
                      it.desc.toLowerCase().contains(q))
                  .toList();
              return matched.isEmpty
                  ? null
                  : _FaqCategory(cat.title, cat.icon, matched);
            })
            .whereType<_FaqCategory>()
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpFaq)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingM,
              AppSizes.spacingS,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.helpSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: AppSizes.spacingM),
                        Text(
                          l10n.helpNoResults,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.spacingM,
                      0,
                      AppSizes.spacingM,
                      AppSizes.spacingM,
                    ),
                    children: [
                      for (final cat in filteredCategories) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSizes.spacingM,
                            bottom: AppSizes.spacingS,
                          ),
                          child: Row(
                            children: [
                              Icon(cat.icon,
                                  size: 18,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                cat.title,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(
                              bottom: AppSizes.spacingS),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusM),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < cat.items.length; i++) ...[
                                ExpansionTile(
                                  shape: const Border(),
                                  collapsedShape: const Border(),
                                  title: Text(
                                    cat.items[i].title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  childrenPadding: const EdgeInsets.fromLTRB(
                                    AppSizes.spacingM,
                                    0,
                                    AppSizes.spacingM,
                                    AppSizes.spacingM,
                                  ),
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.items[i].desc,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: theme
                                            .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (i < cat.items.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}