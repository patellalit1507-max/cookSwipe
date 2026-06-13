import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_card.dart';

/// Instant name search across the whole dataset (in-memory, so results
/// update on every keystroke even offline).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  bool _loggedThisQuery = false;

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final foodsLoading = ref.watch(allFoodsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search dishes… (Dosa, Paneer, Poha)',
            filled: false,
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _loggedThisQuery = false;
            ref.read(searchQueryProvider.notifier).state = value;
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && !_loggedThisQuery) {
              _loggedThisQuery = true;
              ref.read(analyticsProvider).logSearchPerformed(value.trim());
            }
          },
        ),
      ),
      body: _buildBody(query, results, foodsLoading),
    );
  }

  Widget _buildBody(String query, List results, bool loading) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (query.trim().isEmpty) {
      return const EmptyState(
        icon: Icons.search_rounded,
        title: 'Find a dish',
        message: 'Type a dish name — results appear instantly.',
      );
    }
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.no_meals_rounded,
        title: 'No dishes found',
        message: 'Nothing matches "$query". Try a shorter name.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final food = results[index];
        return FoodListTile(
          name: food.name,
          imageUrl: food.imageUrl,
          isVeg: food.isVeg,
          subtitle:
              '${food.category.label} • ${food.prepTime} min • ${food.difficulty.label}',
        );
      },
    );
  }
}
