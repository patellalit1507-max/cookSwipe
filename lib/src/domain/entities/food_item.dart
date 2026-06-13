import '../../core/constants/app_constants.dart';

/// A dish CookSwipe can suggest. Immutable domain entity.
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.region,
    required this.isVeg,
    required this.prepTime,
    required this.difficulty,
    required this.popularityScore,
  });

  final String id;
  final String name;
  final MealCategory category;
  final String imageUrl;

  /// One of [AppRegions.options], another Indian state, or [AppRegions.panIndia].
  final String region;
  final bool isVeg;

  /// Preparation time in minutes.
  final int prepTime;
  final Difficulty difficulty;

  /// 0–100, used as a ranking signal.
  final int popularityScore;

  FoodItem copyWith({
    String? id,
    String? name,
    MealCategory? category,
    String? imageUrl,
    String? region,
    bool? isVeg,
    int? prepTime,
    Difficulty? difficulty,
    int? popularityScore,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      region: region ?? this.region,
      isVeg: isVeg ?? this.isVeg,
      prepTime: prepTime ?? this.prepTime,
      difficulty: difficulty ?? this.difficulty,
      popularityScore: popularityScore ?? this.popularityScore,
    );
  }

  @override
  bool operator ==(Object other) => other is FoodItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
