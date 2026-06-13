import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/ad_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../data/repositories/selection_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/sources/local_dataset_source.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/selection_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/suggestion_engine.dart';

// --- Bootstrap values (overridden in main.dart) ----------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final firebaseAvailableProvider = Provider<bool>((ref) => false);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

// --- Core services ----------------------------------------------------------

final localStorageProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(ref.watch(sharedPreferencesProvider)),
);

final analyticsProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(enabled: ref.watch(firebaseAvailableProvider)),
);

final adServiceProvider = Provider<AdService>(
  (ref) => AdService(ref.watch(localStorageProvider)),
);

final suggestionEngineProvider =
    Provider<SuggestionEngine>((ref) => SuggestionEngine());

// --- Repositories ------------------------------------------------------------

final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => FoodRepositoryImpl(
    firebaseAvailable: ref.watch(firebaseAvailableProvider),
    localSource: LocalDatasetSource(),
  ),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    firebaseAvailable: ref.watch(firebaseAvailableProvider),
    storage: ref.watch(localStorageProvider),
  ),
);

final selectionRepositoryProvider = Provider<SelectionRepository>(
  (ref) => SelectionRepositoryImpl(
    firebaseAvailable: ref.watch(firebaseAvailableProvider),
    storage: ref.watch(localStorageProvider),
    userRepository: ref.watch(userRepositoryProvider),
  ),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepositoryImpl(
    firebaseAvailable: ref.watch(firebaseAvailableProvider),
    storage: ref.watch(localStorageProvider),
    userRepository: ref.watch(userRepositoryProvider),
  ),
);

// --- Data ---------------------------------------------------------------------

final allFoodsProvider = FutureProvider<List<FoodItem>>(
  (ref) => ref.watch(foodRepositoryProvider).getAllFoods(),
);

final isAdminProvider = FutureProvider<bool>(
  (ref) => ref.watch(userRepositoryProvider).isAdmin(),
);

// --- User preferences ------------------------------------------------------------

class UserPreferencesNotifier extends StateNotifier<UserPreferences?> {
  /// [initial] must be loaded synchronously before construction: the swipe
  /// deck is filtered by these preferences, and an async load would let a
  /// fast user reach the deck with no preferences applied (e.g. a
  /// vegetarian briefly seeing non-veg dishes).
  UserPreferencesNotifier(this._repo, UserPreferences? initial)
      : super(initial);

  final UserRepository _repo;

  Future<void> save(UserPreferences prefs) async {
    state = prefs;
    await _repo.savePreferences(prefs);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences?>((ref) {
  // SharedPreferences reads are synchronous, so saved preferences are
  // available from the very first frame — no startup race.
  final storedMap = ref.watch(localStorageProvider).userPreferences;
  final initial =
      storedMap == null ? null : UserPreferences.fromMap(storedMap);
  return UserPreferencesNotifier(ref.watch(userRepositoryProvider), initial);
});

// --- Search ------------------------------------------------------------------------

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<FoodItem>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return const [];
  final foods = ref.watch(allFoodsProvider).asData?.value ?? const <FoodItem>[];
  return foods
      .where((f) => f.name.toLowerCase().contains(query))
      .take(60)
      .toList();
});
