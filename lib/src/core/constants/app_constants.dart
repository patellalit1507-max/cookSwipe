import 'package:flutter/foundation.dart';

/// The four meal categories CookSwipe helps decide.
enum MealCategory {
  breakfast('Breakfast', '🍳'),
  lunch('Lunch', '🍛'),
  snacks('Snacks', '☕'),
  dinner('Dinner', '🍽️');

  const MealCategory(this.label, this.emoji);
  final String label;
  final String emoji;

  static MealCategory fromId(String id) => MealCategory.values.firstWhere(
        (c) => c.name == id.toLowerCase(),
        orElse: () => MealCategory.breakfast,
      );
}

enum FoodPreference {
  vegetarian('Vegetarian'),
  nonVegetarian('Non Vegetarian'),
  both('Both');

  const FoodPreference(this.label);
  final String label;

  static FoodPreference fromId(String id) => FoodPreference.values.firstWhere(
        (p) => p.name == id,
        orElse: () => FoodPreference.both,
      );
}

enum TimePreference {
  under15('Under 15 Minutes', 15),
  under30('Under 30 Minutes', 30),
  any('Any', null);

  const TimePreference(this.label, this.maxMinutes);
  final String label;
  final int? maxMinutes;

  static TimePreference fromId(String id) => TimePreference.values.firstWhere(
        (t) => t.name == id,
        orElse: () => TimePreference.any,
      );
}

enum Difficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const Difficulty(this.label);
  final String label;

  static Difficulty fromId(String id) => Difficulty.values.firstWhere(
        (d) => d.name == id.toLowerCase(),
        orElse: () => Difficulty.medium,
      );
}

class AppRegions {
  AppRegions._();

  /// A dish tagged with this region matches every user.
  static const String panIndia = 'All India';

  /// Onboarding options, in spec order.
  static const List<String> options = [
    'Karnataka',
    'Tamil Nadu',
    'Kerala',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Gujarat',
    'Rajasthan',
    'Punjab',
    'Delhi',
    'West Bengal',
    'Other',
  ];

  /// Regions a dish may be tagged with (admin form + dataset).
  /// Superset of [options]: dishes can come from states that are not
  /// onboarding choices; they simply get no regional ranking boost.
  static const List<String> dishRegions = [
    panIndia,
    'Karnataka',
    'Tamil Nadu',
    'Kerala',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Gujarat',
    'Rajasthan',
    'Punjab',
    'Delhi',
    'West Bengal',
    'Uttar Pradesh',
    'Bihar',
    'Madhya Pradesh',
    'Odisha',
    'Assam',
    'Goa',
    'Kashmir',
    'Other',
  ];
}

class StorageKeys {
  StorageKeys._();

  static const onboardingComplete = 'onboarding_complete';
  static const userPreferences = 'user_preferences';
  static const localUserId = 'local_user_id';
  static const favorites = 'favorites';
  static const selectionHistory = 'selection_history';
  static const todaysMenuPrefix = 'todays_menu_'; // + yyyy-MM-dd
  static const recentlyViewed = 'recently_viewed_ids';
  static const lastAdShownDate = 'last_ad_shown_date';
  static const notificationsEnabled = 'notifications_enabled';
}

class AdConfig {
  AdConfig._();

  /// Google's official TEST interstitial unit id — safe during development.
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  /// TODO: replace with your real AdMob interstitial unit id before release
  /// (also replace the APPLICATION_ID in AndroidManifest.xml).
  static const String _prodInterstitialId = 'ca-app-pub-9451303528131556/9642770469';

  static String get interstitialAdUnitId =>
      kReleaseMode && !_prodInterstitialId.contains('REPLACE')
          ? _prodInterstitialId
          : _testInterstitialId;
}

class AppLimits {
  AppLimits._();

  /// History keeps only the most recent selections.
  static const int historyLimit = 30;

  /// How many recently-viewed dish ids to remember for variety.
  static const int recentlyViewedLimit = 100;

  /// How many cards to queue per swipe session.
  static const int swipeQueueSize = 40;
}
