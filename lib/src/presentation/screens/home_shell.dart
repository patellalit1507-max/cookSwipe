import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/menu_providers.dart';
import '../providers/providers.dart';
import '../widgets/meal_category_card.dart';
import 'favorites_tab.dart';
import 'history_tab.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'swipe_screen.dart';
import 'todays_menu_tab.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  static const _titles = ['CookSwipe', "Today's Menu", 'Favorites', 'History'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search dishes',
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: const [
          _DecideTab(),
          TodaysMenuTab(),
          FavoritesTab(),
          HistoryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.saffron.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded, color: AppTheme.saffron),
            label: 'Decide',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon:
                Icon(Icons.restaurant_rounded, color: AppTheme.saffron),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon:
                Icon(Icons.favorite_rounded, color: AppTheme.saffron),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded, color: AppTheme.saffron),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

/// Home tab: greeting + the four large meal category cards.
class _DecideTab extends ConsumerWidget {
  const _DecideTab();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Good morning! ☀️';
    if (hour < 16) return 'Good afternoon! 🌤️';
    return 'Good evening! 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(todaysMenuProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          _greeting,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        const Text(
          'What should we\ncook today?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.8,
            color: AppTheme.deepCharcoal,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
          children: [
            for (final category in MealCategory.values)
              MealCategoryCard(
                category: category,
                selectedDish: menu[category]?.foodName,
                onTap: () {
                  ref.read(analyticsProvider).logCategoryOpened(category);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SwipeScreen(category: category),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Tap a meal, swipe right on what you like.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}
