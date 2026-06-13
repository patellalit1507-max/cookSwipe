import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';

/// Thin typed wrapper over SharedPreferences. This is the local source of
/// truth — Firestore writes are best-effort sync on top of it, which gives
/// the app full offline support.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // --- Onboarding ---------------------------------------------------------

  bool get onboardingComplete =>
      _prefs.getBool(StorageKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete() =>
      _prefs.setBool(StorageKeys.onboardingComplete, true);

  // --- Identity -----------------------------------------------------------

  /// Locally generated id, used when Firebase auth is unavailable.
  String get localUserId {
    var id = _prefs.getString(StorageKeys.localUserId);
    if (id == null) {
      id = const Uuid().v4();
      _prefs.setString(StorageKeys.localUserId, id);
    }
    return id;
  }

  // --- User preferences ---------------------------------------------------

  Map<String, dynamic>? get userPreferences =>
      _readJsonMap(StorageKeys.userPreferences);

  Future<void> saveUserPreferences(Map<String, dynamic> map) =>
      _prefs.setString(StorageKeys.userPreferences, jsonEncode(map));

  // --- Favorites ----------------------------------------------------------

  List<Map<String, dynamic>> get favorites =>
      _readJsonList(StorageKeys.favorites);

  Future<void> saveFavorites(List<Map<String, dynamic>> items) =>
      _prefs.setString(StorageKeys.favorites, jsonEncode(items));

  // --- Selection history (last 30) ----------------------------------------

  List<Map<String, dynamic>> get selectionHistory =>
      _readJsonList(StorageKeys.selectionHistory);

  Future<void> saveSelectionHistory(List<Map<String, dynamic>> items) =>
      _prefs.setString(
        StorageKeys.selectionHistory,
        jsonEncode(items.take(AppLimits.historyLimit).toList()),
      );

  // --- Today's menu (keyed by date so it resets daily) ---------------------

  Map<String, dynamic> get todaysMenu =>
      _readJsonMap('${StorageKeys.todaysMenuPrefix}${todayKey()}') ?? {};

  Future<void> saveTodaysMenu(Map<String, dynamic> menu) => _prefs.setString(
      '${StorageKeys.todaysMenuPrefix}${todayKey()}', jsonEncode(menu));

  // --- Recently viewed (for suggestion variety) ----------------------------

  List<String> get recentlyViewedIds =>
      _prefs.getStringList(StorageKeys.recentlyViewed) ?? const [];

  Future<void> addRecentlyViewed(String foodId) {
    final ids = [...recentlyViewedIds]
      ..remove(foodId)
      ..add(foodId);
    if (ids.length > AppLimits.recentlyViewedLimit) {
      ids.removeRange(0, ids.length - AppLimits.recentlyViewedLimit);
    }
    return _prefs.setStringList(StorageKeys.recentlyViewed, ids).then((_) {});
  }

  Future<void> clearRecentlyViewed() =>
      _prefs.remove(StorageKeys.recentlyViewed).then((_) {});

  // --- Ad frequency cap (one interstitial per day, stored locally) ---------

  String? get lastAdShownDate => _prefs.getString(StorageKeys.lastAdShownDate);

  Future<void> setLastAdShownDate(String date) =>
      _prefs.setString(StorageKeys.lastAdShownDate, date);

  // --- Notifications toggle -------------------------------------------------

  bool get notificationsEnabled =>
      _prefs.getBool(StorageKeys.notificationsEnabled) ?? true;

  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(StorageKeys.notificationsEnabled, value);

  // --- Helpers --------------------------------------------------------------

  Map<String, dynamic>? _readJsonMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _readJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    } catch (_) {
      return [];
    }
  }
}
