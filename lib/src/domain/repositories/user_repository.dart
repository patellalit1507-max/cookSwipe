import '../entities/user_preferences.dart';

abstract class UserRepository {
  /// Stable id for this user (Firebase anonymous uid, or a locally
  /// generated uuid when Firebase is unavailable).
  String get userId;

  Future<UserPreferences?> loadPreferences();

  /// Saves locally always, and best-effort to Firestore `users/{uid}`.
  Future<void> savePreferences(UserPreferences preferences);

  /// True when the Firestore user document has role == 'admin'.
  Future<bool> isAdmin();
}
