import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/services/local_storage_service.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/food_item_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({
    required bool firebaseAvailable,
    required LocalStorageService storage,
    required UserRepository userRepository,
  })  : _firebaseAvailable = firebaseAvailable,
        _storage = storage,
        _users = userRepository;

  final bool _firebaseAvailable;
  final LocalStorageService _storage;
  final UserRepository _users;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('favorites');

  @override
  Future<List<FoodItem>> getFavorites() async {
    return [for (final map in _storage.favorites) FoodItemModel.fromJson(map)];
  }

  @override
  Future<void> addFavorite(FoodItem item) async {
    final model = FoodItemModel.fromEntity(item);
    final current = _storage.favorites
      ..removeWhere((m) => m['id'] == item.id)
      ..insert(0, model.toJson());
    await _storage.saveFavorites(current);

    if (_firebaseAvailable) {
      try {
        await _col.doc('${_users.userId}_${item.id}').set({
          'userId': _users.userId,
          'food': model.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Favorite sync to Firestore failed: $e');
      }
    }
  }

  @override
  Future<void> removeFavorite(String foodId) async {
    final current = _storage.favorites
      ..removeWhere((m) => m['id'] == foodId);
    await _storage.saveFavorites(current);

    if (_firebaseAvailable) {
      try {
        await _col.doc('${_users.userId}_$foodId').delete();
      } catch (e) {
        debugPrint('Favorite removal sync failed: $e');
      }
    }
  }
}
