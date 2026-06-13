import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/local_storage_service.dart';
import '../../domain/entities/meal_selection.dart';
import '../../domain/repositories/selection_repository.dart';
import '../../domain/repositories/user_repository.dart';

class SelectionRepositoryImpl implements SelectionRepository {
  SelectionRepositoryImpl({
    required bool firebaseAvailable,
    required LocalStorageService storage,
    required UserRepository userRepository,
  })  : _firebaseAvailable = firebaseAvailable,
        _storage = storage,
        _users = userRepository;

  final bool _firebaseAvailable;
  final LocalStorageService _storage;
  final UserRepository _users;

  @override
  Future<Map<MealCategory, MealSelection>> getTodaysMenu() async {
    final raw = _storage.todaysMenu;
    return {
      for (final entry in raw.entries)
        if (entry.value is Map<String, dynamic>)
          MealCategory.fromId(entry.key):
              MealSelection.fromMap(entry.value as Map<String, dynamic>),
    };
  }

  @override
  Future<void> saveSelection(MealSelection selection) async {
    // Local first: today's menu slot (replace semantics) + history.
    final menu = _storage.todaysMenu;
    menu[selection.category.name] = selection.toMap();
    await _storage.saveTodaysMenu(menu);

    final history = _storage.selectionHistory..insert(0, selection.toMap());
    await _storage.saveSelectionHistory(history);

    // Best-effort cloud sync.
    if (_firebaseAvailable) {
      try {
        await FirebaseFirestore.instance
            .collection('selections')
            .doc(selection.id)
            .set({
          ...selection.toMap(),
          'userId': _users.userId,
          'date': LocalStorageService.todayKey(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Selection sync to Firestore failed: $e');
      }
    }
  }

  @override
  Future<List<MealSelection>> getHistory() async {
    return [
      for (final map in _storage.selectionHistory.take(AppLimits.historyLimit))
        MealSelection.fromMap(map),
    ];
  }
}
