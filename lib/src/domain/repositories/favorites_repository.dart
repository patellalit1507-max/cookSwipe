import '../entities/food_item.dart';

abstract class FavoritesRepository {
  Future<List<FoodItem>> getFavorites();
  Future<void> addFavorite(FoodItem item);
  Future<void> removeFavorite(String foodId);
}
