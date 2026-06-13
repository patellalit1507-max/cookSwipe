import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/food_item.dart';
import 'dish_image.dart';
import 'veg_indicator.dart';

/// The swipe card: full-bleed dish photo, name, prep time, difficulty
/// and the veg/non-veg mark.
class FoodCard extends StatelessWidget {
  const FoodCard({super.key, required this.food});

  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DishImage(imageUrl: food.imageUrl),
          // Bottom gradient for text legibility.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VegIndicator(isVeg: food.isVeg),
                    const SizedBox(width: 8),
                    Text(
                      food.isVeg ? 'Vegetarian' : 'Non-Veg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  food.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.schedule_rounded,
                      label: '${food.prepTime} min',
                    ),
                    _InfoPill(
                      icon: Icons.local_fire_department_rounded,
                      label: food.difficulty.label,
                    ),
                    if (food.region != 'All India')
                      _InfoPill(
                        icon: Icons.place_rounded,
                        label: food.region,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact list tile used by Favorites / Search / History rows.
class FoodListTile extends StatelessWidget {
  const FoodListTile({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isVeg,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String name;
  final String imageUrl;
  final bool isVeg;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 56,
            height: 56,
            child: DishImage(imageUrl: imageUrl),
          ),
        ),
        title: Row(
          children: [
            VegIndicator(isVeg: isVeg, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepCharcoal,
                ),
              ),
            ),
          ],
        ),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!,
                    style: TextStyle(color: Colors.grey.shade600)),
              ),
        trailing: trailing,
      ),
    );
  }
}
