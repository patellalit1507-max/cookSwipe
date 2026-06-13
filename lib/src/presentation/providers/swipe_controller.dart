import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_selection.dart';
import '../../domain/entities/user_preferences.dart';
import 'menu_providers.dart';
import 'providers.dart';

class SwipeState {
  const SwipeState({
    this.queue = const [],
    this.loading = true,
    this.error,
  });

  final List<FoodItem> queue;
  final bool loading;
  final String? error;
}

/// Drives one swipe session for a meal category: builds the ranked deck,
/// records views/skips, and commits right-swipes (selection + favorite +
/// history + analytics).
class SwipeController extends StateNotifier<SwipeState> {
  SwipeController(this._ref, this._category) : super(const SwipeState()) {
    loadQueue();
  }

  final Ref _ref;
  final MealCategory _category;

  static const _fallbackPrefs = UserPreferences(
    foodPreference: FoodPreference.both,
    region: 'Other',
    timePreference: TimePreference.any,
  );

  Future<void> loadQueue({bool relaxVariety = false}) async {
    state = const SwipeState(loading: true);
    try {
      final storage = _ref.read(localStorageProvider);
      if (relaxVariety) {
        // User exhausted the deck: forget "recently viewed" so every
        // matching dish becomes suggestible again.
        await storage.clearRecentlyViewed();
      }
      final foods = await _ref.read(foodRepositoryProvider).getAllFoods();
      final prefs = _ref.read(userPreferencesProvider) ?? _fallbackPrefs;
      final history =
          await _ref.read(selectionRepositoryProvider).getHistory();

      final queue = _ref.read(suggestionEngineProvider).buildQueue(
            pool: foods,
            category: _category,
            prefs: prefs,
            recentlyViewedIds: storage.recentlyViewedIds.toSet(),
            recentlySelectedIds: {for (final s in history) s.foodId},
          );
      state = SwipeState(queue: queue, loading: false);
    } catch (e) {
      state = SwipeState(
        loading: false,
        error: 'Could not load suggestions. Please try again.',
      );
    }
  }

  void onCardShown(FoodItem food) {
    _ref.read(localStorageProvider).addRecentlyViewed(food.id);
    _ref.read(analyticsProvider).logDishViewed(food);
  }

  /// Left swipe — "show another suggestion".
  void skip(FoodItem food) {
    _ref.read(analyticsProvider).logDishSkipped(food);
  }

  /// Right swipe — "I want this dish".
  Future<void> select(FoodItem food) async {
    final selection = MealSelection.fromFood(food, id: const Uuid().v4());
    await _ref.read(todaysMenuProvider.notifier).select(selection);
    await _ref.read(favoritesProvider.notifier).add(food);
    await _ref.read(historyProvider.notifier).refresh();
    final analytics = _ref.read(analyticsProvider);
    analytics.logDishSelected(food);
    analytics.logFavoriteAdded(food);
  }
}

final swipeControllerProvider = StateNotifierProvider.autoDispose
    .family<SwipeController, SwipeState, MealCategory>(
  (ref, category) => SwipeController(ref, category),
);
