import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:cookswipe/src/core/constants/app_constants.dart';
import 'package:cookswipe/src/domain/entities/food_item.dart';
import 'package:cookswipe/src/domain/entities/user_preferences.dart';
import 'package:cookswipe/src/domain/usecases/suggestion_engine.dart';

FoodItem food(
  String id, {
  MealCategory category = MealCategory.breakfast,
  bool isVeg = true,
  int prepTime = 20,
  String region = AppRegions.panIndia,
  int popularity = 50,
}) {
  return FoodItem(
    id: id,
    name: id,
    category: category,
    imageUrl: '',
    region: region,
    isVeg: isVeg,
    prepTime: prepTime,
    difficulty: Difficulty.easy,
    popularityScore: popularity,
  );
}

void main() {
  final engine = SuggestionEngine(random: Random(42));

  const vegPrefs = UserPreferences(
    foodPreference: FoodPreference.vegetarian,
    region: 'Karnataka',
    timePreference: TimePreference.under30,
  );

  test('filters by category', () {
    final queue = engine.buildQueue(
      pool: [
        food('idli'),
        food('dal', category: MealCategory.lunch),
      ],
      category: MealCategory.breakfast,
      prefs: vegPrefs,
      recentlyViewedIds: {},
      recentlySelectedIds: {},
    );
    expect(queue.map((f) => f.id), ['idli']);
  });

  test('vegetarians never see non-veg dishes', () {
    final queue = engine.buildQueue(
      pool: [food('omelette', isVeg: false), food('poha')],
      category: MealCategory.breakfast,
      prefs: vegPrefs,
      recentlyViewedIds: {},
      recentlySelectedIds: {},
    );
    expect(queue.every((f) => f.isVeg), isTrue);
  });

  test('respects cooking time preference', () {
    final queue = engine.buildQueue(
      pool: [food('quick', prepTime: 10), food('slow', prepTime: 60)],
      category: MealCategory.breakfast,
      prefs: vegPrefs,
      recentlyViewedIds: {},
      recentlySelectedIds: {},
    );
    expect(queue.map((f) => f.id), ['quick']);
  });

  test('unseen dishes rank above recently viewed ones', () {
    final pool = [
      food('seen', popularity: 100, region: 'Karnataka'),
      food('unseen', popularity: 10),
    ];
    final queue = engine.buildQueue(
      pool: pool,
      category: MealCategory.breakfast,
      prefs: vegPrefs,
      recentlyViewedIds: {'seen'},
      recentlySelectedIds: {},
    );
    expect(queue.first.id, 'unseen');
  });

  test('recently selected dishes sink to the bottom but remain available',
      () {
    final pool = [food('cooked-yesterday'), food('fresh-idea')];
    final queue = engine.buildQueue(
      pool: pool,
      category: MealCategory.breakfast,
      prefs: vegPrefs,
      recentlyViewedIds: {},
      recentlySelectedIds: {'cooked-yesterday'},
    );
    expect(queue.length, 2);
    expect(queue.first.id, 'fresh-idea');
  });
}
