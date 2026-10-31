import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/screen_breakpoints.dart';
import '../../providers/collection_provider.dart';
import 'home/home_page.dart';
import 'catalog/catalog_page.dart';
import 'collection/collection_page.dart';
import 'other/other_page.dart';
import 'profile/profile_page.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  final Set<int> _built = {0};
  final GlobalKey _stackKey = GlobalKey();

  late final List<Widget> _pages = [
    HomePage(onNavigateTab: _onNavigateTab),
    const CatalogPage(),
    const CollectionPage(),
    const OtherPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final provider = context.read<CollectionProvider>();

    if (state == AppLifecycleState.resumed) {
      if (provider.isOffline) {
        provider.retryConnection();
      }
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.inactive) {
      provider.flushCache();
    }
  }

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
      _built.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.navHome,
      ),
      NavigationDestination(
        icon: const Icon(Icons.explore_outlined),
        selectedIcon: const Icon(Icons.explore),
        label: l10n.navCatalog,
      ),
      NavigationDestination(
        icon: const Icon(Icons.collections_bookmark_outlined),
        selectedIcon: const Icon(Icons.collections_bookmark),
        label: l10n.navCollection,
      ),
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: l10n.navOther,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l10n.navProfile,
      ),
    ];

    List<NavigationRailDestination> railDestinations = destinations.map((dest) {
      return NavigationRailDestination(
        icon: dest.icon,
        selectedIcon: dest.selectedIcon,
        label: Text(dest.label),
      );
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_currentIndex != 0) {
          _onNavigateTab(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width >= ScreenBreakpoints.medium) {
            return _buildRailLayout(
              labelType: NavigationRailLabelType.all,
              destinations: railDestinations,
            );
          }

          if (width >= ScreenBreakpoints.compact) {
            return _buildRailLayout(
              labelType: NavigationRailLabelType.none,
              destinations: railDestinations,
            );
          }

          return _buildBottomNavLayout(destinations);
        },
      ),
    );
  }

  Widget _buildRailLayout({
    required NavigationRailLabelType labelType,
    required List<NavigationRailDestination> destinations,
  }) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigateTab,
              labelType: labelType,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(
                  Icons.menu_book,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              destinations: destinations,
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildLazyStack(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavLayout(List<NavigationDestination> destinations) {
    return Scaffold(
      body: _buildLazyStack(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigateTab,
        destinations: destinations,
      ),
    );
  }

  Widget _buildLazyStack() {
    return IndexedStack(
      key: _stackKey,
      index: _currentIndex,
      children: [
        for (var i = 0; i < _pages.length; i++)
          _built.contains(i) ? _pages[i] : const SizedBox.shrink(),
      ],
    );
  }
}