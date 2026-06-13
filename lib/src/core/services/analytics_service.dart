import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/food_item.dart';
import '../constants/app_constants.dart';

/// Firebase Analytics wrapper. Every method is a silent no-op when
/// Firebase is unavailable, so callers never need to branch.
class AnalyticsService {
  AnalyticsService({required bool enabled}) : _enabled = enabled;

  final bool _enabled;

  FirebaseAnalytics? get _analytics =>
      _enabled ? FirebaseAnalytics.instance : null;

  Future<void> logCategoryOpened(MealCategory category) =>
      _log('meal_category_opened', {'category': category.name});

  Future<void> logDishViewed(FoodItem food) => _log('dish_viewed', {
        'dish_id': food.id,
        'dish_name': food.name,
        'category': food.category.name,
      });

  Future<void> logDishSelected(FoodItem food) => _log('dish_selected', {
        'dish_id': food.id,
        'dish_name': food.name,
        'category': food.category.name,
      });

  Future<void> logDishSkipped(FoodItem food) => _log('dish_skipped', {
        'dish_id': food.id,
        'dish_name': food.name,
        'category': food.category.name,
      });

  Future<void> logFavoriteAdded(FoodItem food) => _log('favorite_added', {
        'dish_id': food.id,
        'dish_name': food.name,
      });

  Future<void> logSearchPerformed(String query) =>
      _log('search_performed', {'query': query});

  Future<void> _log(String name, Map<String, Object> params) async {
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics "$name" failed: $e');
    }
  }
}
