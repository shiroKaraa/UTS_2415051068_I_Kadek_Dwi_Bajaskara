import 'package:flutter/material.dart';
import '../core/screen_breakpoints.dart';
import 'home_page.dart';
import 'catalog_page.dart';
import 'collection_page.dart';
import 'other_page.dart';
import 'profile_page.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CatalogPage(),
    CollectionPage(),
    OtherPage(),
    ProfilePage(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Katalog',
    ),
    NavigationDestination(
      icon: Icon(Icons.collections_bookmark_outlined),
      selectedIcon: Icon(Icons.collections_bookmark),
      label: 'Koleksi',
    ),
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Lainnya',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  List<NavigationRailDestination> get _railDestinations {
    return _destinations.map((dest) {
      return NavigationRailDestination(
        icon: dest.icon,
        selectedIcon: dest.selectedIcon,
        label: Text(dest.label),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // --- EXPANDED: tablet landscape / desktop → rail + label ---
        if (width >= ScreenBreakpoints.medium) {
          return _buildRailLayout(
            labelType: NavigationRailLabelType.all,
          );
        }

        // --- MEDIUM: tablet portrait → rail tanpa label ---
        if (width >= ScreenBreakpoints.compact) {
          return _buildRailLayout(
            labelType: NavigationRailLabelType.none,
          );
        }

        // --- COMPACT: HP → bottom navigation ---
        return _buildBottomNavLayout();
      },
    );
  }

  Widget _buildRailLayout({required NavigationRailLabelType labelType}) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              labelType: labelType,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(
                  Icons.menu_book,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              destinations: _railDestinations,
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavLayout() {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }
}