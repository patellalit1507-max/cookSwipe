import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/meal_selection.dart';
import '../providers/menu_providers.dart';
import '../widgets/dish_image.dart';
import '../widgets/veg_indicator.dart';
import 'swipe_screen.dart';

/// Today's Menu: the chosen dish for each meal, with replace support.
class TodaysMenuTab extends ConsumerWidget {
  const TodaysMenuTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(todaysMenuProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(todaysMenuProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in MealCategory.values)
            _MenuSlot(category: category, selection: menu[category]),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Your menu resets every day.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSlot extends ConsumerWidget {
  const _MenuSlot({required this.category, required this.selection});

  final MealCategory category;
  final MealSelection? selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = this.selection;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: selection != null
                    ? DishImage(imageUrl: selection.imageUrl)
                    : Container(
                        color: AppTheme.saffron.withValues(alpha: 0.1),
                        alignment: Alignment.center,
                        child: Text(category.emoji,
                            style: const TextStyle(fontSize: 30)),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${category.emoji} ${category.label}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (selection != null)
                    Row(
                      children: [
                        VegIndicator(
                            isVeg: selection.isVeg, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selection.foodName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.deepCharcoal,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Not decided yet',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SwipeScreen(category: category),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.saffron,
                side: const BorderSide(color: AppTheme.saffron),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(selection != null ? 'Replace' : 'Decide'),
            ),
          ],
        ),
      ),
    );
  }
}
