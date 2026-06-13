import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/food_item.dart';

/// Serialization layer for [FoodItem]. The JSON shape matches the
/// Firestore `foodItems` document schema and the bundled dataset file.
class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.imageUrl,
    required super.region,
    required super.isVeg,
    required super.prepTime,
    required super.difficulty,
    required super.popularityScore,
  });

  factory FoodItemModel.fromEntity(FoodItem item) => FoodItemModel(
        id: item.id,
        name: item.name,
        category: item.category,
        imageUrl: item.imageUrl,
        region: item.region,
        isVeg: item.isVeg,
        prepTime: item.prepTime,
        difficulty: item.difficulty,
        popularityScore: item.popularityScore,
      );

  factory FoodItemModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return FoodItemModel(
      id: id ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown dish',
      category: MealCategory.fromId(json['category'] as String? ?? ''),
      imageUrl: json['imageUrl'] as String? ?? '',
      region: json['region'] as String? ?? AppRegions.panIndia,
      isVeg: json['isVeg'] as bool? ?? true,
      prepTime: (json['prepTime'] as num?)?.toInt() ?? 30,
      difficulty: Difficulty.fromId(json['difficulty'] as String? ?? ''),
      popularityScore: (json['popularityScore'] as num?)?.toInt() ?? 50,
    );
  }

  factory FoodItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      FoodItemModel.fromJson(doc.data() ?? const {}, id: doc.id);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'imageUrl': imageUrl,
        'region': region,
        'isVeg': isVeg,
        'prepTime': prepTime,
        'difficulty': difficulty.name,
        'popularityScore': popularityScore,
      };
}
