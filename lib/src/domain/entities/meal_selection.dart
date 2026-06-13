import '../../core/constants/app_constants.dart';
import 'food_item.dart';

/// A dish the user committed to cook (a right swipe).
class MealSelection {
  const MealSelection({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.imageUrl,
    required this.category,
    required this.isVeg,
    required this.prepTime,
    required this.selectedAt,
  });

  final String id;
  final String foodId;
  final String foodName;
  final String imageUrl;
  final MealCategory category;
  final bool isVeg;
  final int prepTime;
  final DateTime selectedAt;

  factory MealSelection.fromFood(FoodItem food, {required String id}) {
    return MealSelection(
      id: id,
      foodId: food.id,
      foodName: food.name,
      imageUrl: food.imageUrl,
      category: food.category,
      isVeg: food.isVeg,
      prepTime: food.prepTime,
      selectedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'foodId': foodId,
        'foodName': foodName,
        'imageUrl': imageUrl,
        'category': category.name,
        'isVeg': isVeg,
        'prepTime': prepTime,
        'selectedAt': selectedAt.toIso8601String(),
      };

  factory MealSelection.fromMap(Map<String, dynamic> map) {
    return MealSelection(
      id: map['id'] as String? ?? '',
      foodId: map['foodId'] as String? ?? '',
      foodName: map['foodName'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      category: MealCategory.fromId(map['category'] as String? ?? ''),
      isVeg: map['isVeg'] as bool? ?? true,
      prepTime: (map['prepTime'] as num?)?.toInt() ?? 0,
      selectedAt: DateTime.tryParse(map['selectedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
