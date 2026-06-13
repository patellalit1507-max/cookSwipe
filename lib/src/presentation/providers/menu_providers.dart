import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal_selection.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/selection_repository.dart';
import 'providers.dart';

// --- Today's menu -----------------------------------------------------------

class TodaysMenuNotifier
    extends StateNotifier<Map<MealCategory, MealSelection>> {
  TodaysMenuNotifier(this._repo) : super(const {}) {
    refresh();
  }

  final SelectionRepository _repo;

  Future<void> refresh() async {
    state = await _repo.getTodaysMenu();
  }

  /// Fills (or replaces) today's slot for the selection's category.
  Future<void> select(MealSelection selection) async {
    await _repo.saveSelection(selection);
    state = {...state, selection.category: selection};
  }
}

final todaysMenuProvider =
    StateNotifierProvider<TodaysMenuNotifier, Map<MealCategory, MealSelection>>(
  (ref) => TodaysMenuNotifier(ref.watch(selectionRepositoryProvider)),
);

// --- Favorites ----------------------------------------------------------------

class FavoritesNotifier extends StateNotifier<List<FoodItem>> {
  FavoritesNotifier(this._repo) : super(const []) {
    refresh();
  }

  final FavoritesRepository _repo;

  Future<void> refresh() async {
    state = await _repo.getFavorites();
  }

  Future<void> add(FoodItem item) async {
    await _repo.addFavorite(item);
    state = [item, ...state.where((f) => f.id != item.id)];
  }

  Future<void> remove(String foodId) async {
    await _repo.removeFavorite(foodId);
    state = state.where((f) => f.id != foodId).toList();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<FoodItem>>(
  (ref) => FavoritesNotifier(ref.watch(favoritesRepositoryProvider)),
);

// --- History --------------------------------------------------------------------

class HistoryNotifier extends StateNotifier<List<MealSelection>> {
  HistoryNotifier(this._repo) : super(const []) {
    refresh();
  }

  final SelectionRepository _repo;

  Future<void> refresh() async {
    state = await _repo.getHistory();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<MealSelection>>(
  (ref) => HistoryNotifier(ref.watch(selectionRepositoryProvider)),
);
