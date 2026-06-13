import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/local_storage_service.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required bool firebaseAvailable,
    required LocalStorageService storage,
  })  : _firebaseAvailable = firebaseAvailable,
        _storage = storage;

  final bool _firebaseAvailable;
  final LocalStorageService _storage;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(userId);

  @override
  String get userId {
    if (_firebaseAvailable) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) return uid;
    }
    return _storage.localUserId;
  }

  @override
  Future<UserPreferences?> loadPreferences() async {
    final map = _storage.userPreferences;
    return map == null ? null : UserPreferences.fromMap(map);
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    await _storage.saveUserPreferences(preferences.toMap());
    if (_firebaseAvailable) {
      try {
        await _userDoc.set({
          ...preferences.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Preference sync to Firestore failed: $e');
      }
    }
  }

  @override
  Future<bool> isAdmin() async {
    if (!_firebaseAvailable) return false;
    try {
      final doc = await _userDoc.get();
      return doc.data()?['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }
}
