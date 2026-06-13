import 'dart:math';

import '../../core/constants/app_constants.dart';
import '../entities/food_item.dart';
import '../entities/user_preferences.dart';

/// Ranks dishes for the swipe deck.
///
/// Hard filters: category, vegetarian rule, cooking-time preference.
/// Soft ranking: unseen dishes first, then regional relevance and
/// popularity, with a random jitter for variety. Recently selected
/// dishes are pushed to the bottom rather than removed, so the deck
/// never runs dry for small candidate pools.
class SuggestionEngine {
  SuggestionEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<FoodItem> buildQueue({
    required List<FoodItem> pool,
    required MealCategory category,
    required UserPreferences prefs,
    required Set<String> recentlyViewedIds,
    required Set<String> recentlySelectedIds,
    int limit = AppLimits.swipeQueueSize,
  }) {
    final candidates = pool.where((f) {
      if (f.category != category) return false;
      // Vegetarians never see non-veg. Non-veg users see everything
      // (non-veg dishes get a ranking boost below).
      if (prefs.foodPreference == FoodPreference.vegetarian && !f.isVeg) {
        return false;
      }
      final maxMinutes = prefs.timePreference.maxMinutes;
      if (maxMinutes != null && f.prepTime > maxMinutes) return false;
      return true;
    }).toList();

    double score(FoodItem f) {
      var s = f.popularityScore / 10.0; // 0–10
      if (!recentlyViewedIds.contains(f.id)) s += 50;
      if (recentlySelectedIds.contains(f.id)) s -= 60;
      if (f.region == prefs.region) s += 30;
      if (f.region == AppRegions.panIndia) s += 10;
      if (prefs.foodPreference == FoodPreference.nonVegetarian && !f.isVeg) {
        s += 15;
      }
      s += _random.nextDouble() * 20; // variety jitter
      return s;
    }

    final scored = [for (final f in candidates) (food: f, score: score(f))]
      ..sort((a, b) => b.score.compareTo(a.score));
    return [for (final e in scored.take(limit)) e.food];
  }
}
