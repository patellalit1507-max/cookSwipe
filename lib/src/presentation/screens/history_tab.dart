import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/menu_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_card.dart';

/// Last 30 selections, newest first.
class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'Nothing cooked yet',
        message:
            'Dishes you decide to cook will show up here — your last 30 picks.',
      );
    }

    final formatter = DateFormat('d MMM • h:mm a');
    return RefreshIndicator(
      onRefresh: () => ref.read(historyProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return FoodListTile(
            name: item.foodName,
            imageUrl: item.imageUrl,
            isVeg: item.isVeg,
            subtitle:
                '${item.category.emoji} ${item.category.label} • ${formatter.format(item.selectedAt)}',
          );
        },
      ),
    );
  }
}
