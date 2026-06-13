import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/food_item_model.dart';

/// Loads the bundled food dataset (assets/data/food_dataset.json).
///
/// Used as the offline fallback when Firestore is unreachable or has not
/// been seeded yet, so the MVP is fully usable out of the box.
class LocalDatasetSource {
  static const _assetPath = 'assets/data/food_dataset.json';

  Future<List<FoodItemModel>> loadDataset() async {
    final raw = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(raw) as List;
    return [
      for (final item in list.whereType<Map<String, dynamic>>())
        FoodItemModel.fromJson(item),
    ];
  }
}
