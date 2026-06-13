import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';
import '../models/food_item_model.dart';
import '../sources/local_dataset_source.dart';

class FoodRepositoryImpl implements FoodRepository {
  FoodRepositoryImpl({
    required bool firebaseAvailable,
    required LocalDatasetSource localSource,
  })  : _firebaseAvailable = firebaseAvailable,
        _localSource = localSource;

  final bool _firebaseAvailable;
  final LocalDatasetSource _localSource;
  List<FoodItem>? _cache;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('foodItems');

  @override
  Future<List<FoodItem>> getAllFoods({bool forceRefresh = false}) async {
    if (_cache != null && !forceRefresh) return _cache!;

    if (_firebaseAvailable) {
      try {
        // cloud_firestore's local persistence is enabled by default on
        // Android, so this also works offline once data has been fetched.
        final snapshot = await _col.get();
        if (snapshot.docs.isNotEmpty) {
          _cache = [for (final d in snapshot.docs) FoodItemModel.fromDoc(d)];
          return _cache!;
        }
        debugPrint('foodItems collection is empty — using bundled dataset. '
            'Seed Firestore with tool/seed_firestore.mjs.');
      } catch (e) {
        debugPrint('Firestore fetch failed, using bundled dataset: $e');
      }
    }

    _cache = await _localSource.loadDataset();
    return _cache!;
  }

  @override
  Future<void> addFood(FoodItem item) async {
    _requireFirebase();
    await _col.doc(item.id).set(FoodItemModel.fromEntity(item).toJson());
    _cache = null;
  }

  @override
  Future<void> updateFood(FoodItem item) async {
    _requireFirebase();
    await _col.doc(item.id).set(FoodItemModel.fromEntity(item).toJson());
    _cache = null;
  }

  @override
  Future<void> deleteFood(String id) async {
    _requireFirebase();
    await _col.doc(id).delete();
    _cache = null;
  }

  @override
  Future<String> uploadFoodImage(File file, String foodId) async {
    _requireFirebase();
    final ref = FirebaseStorage.instance.ref('food_images/$foodId.jpg');
    await ref.putFile(
        file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  void _requireFirebase() {
    if (!_firebaseAvailable) {
      throw StateError(
          'Admin operations require Firebase — run flutterfire configure.');
    }
  }
}
