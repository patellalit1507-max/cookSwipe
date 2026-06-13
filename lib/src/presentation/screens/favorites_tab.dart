import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/menu_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_card.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    if (favorites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_outline_rounded,
        title: 'No favorites yet',
        message:
            'Every dish you swipe right on lands here, so your best picks are always one tap away.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final food = favorites[index];
        return FoodListTile(
          name: food.name,
          imageUrl: food.imageUrl,
          isVeg: food.isVeg,
          subtitle:
              '${food.category.label} • ${food.prepTime} min • ${food.difficulty.label}',
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Remove favorite',
            onPressed: () =>
                ref.read(favoritesProvider.notifier).remove(food.id),
          ),
        );
      },
    );
  }
}
