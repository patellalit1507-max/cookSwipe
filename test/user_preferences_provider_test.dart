import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cookswipe/src/core/constants/app_constants.dart';
import 'package:cookswipe/src/presentation/providers/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'saved preferences are available synchronously on first read '
      '(regression: vegetarians briefly saw non-veg on cold start)',
      () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.userPreferences: jsonEncode({
        'foodPreference': FoodPreference.vegetarian.name,
        'region': 'Karnataka',
        'timePreference': TimePreference.under30.name,
        'notificationsEnabled': true,
      }),
    });
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);

    // The very first read — with no async gap — must already reflect the
    // stored preferences, because the swipe deck is built from them.
    final loaded = container.read(userPreferencesProvider);
    expect(loaded, isNotNull);
    expect(loaded!.foodPreference, FoodPreference.vegetarian);
    expect(loaded.region, 'Karnataka');
    expect(loaded.timePreference, TimePreference.under30);
  });
}
