import 'dart:io';

import '../entities/food_item.dart';

abstract class FoodRepository {
  /// All dishes, from Firestore when available, otherwise from the bundled
  /// dataset. Results are cached in memory for the session.
  Future<List<FoodItem>> getAllFoods({bool forceRefresh = false});

  // Admin operations (require Firestore + admin role).
  Future<void> addFood(FoodItem item);
  Future<void> updateFood(FoodItem item);
  Future<void> deleteFood(String id);
  Future<String> uploadFoodImage(File file, String foodId);
}
