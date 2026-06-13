import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Large tappable card on Home for each meal category.
/// Gradient + emoji art keeps it beautiful with zero network dependency.
class MealCategoryCard extends StatelessWidget {
  const MealCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.selectedDish,
  });

  final MealCategory category;
  final VoidCallback onTap;

  /// If today's menu already has a dish for this category, show it.
  final String? selectedDish;

  static const _gradients = {
    MealCategory.breakfast: [Color(0xFFFFB75E), Color(0xFFED8F03)],
    MealCategory.lunch: [Color(0xFFFF8008), Color(0xFFFC4A1A)],
    MealCategory.snacks: [Color(0xFF7B4397), Color(0xFFDC2430)],
    MealCategory.dinner: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[category]!;
    return Material(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 40)),
                const Spacer(),
                Text(
                  category.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedDish ?? 'Tap to decide',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight:
                        selectedDish != null ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
