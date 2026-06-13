import '../../core/constants/app_constants.dart';
import '../entities/meal_selection.dart';

abstract class SelectionRepository {
  /// Today's chosen dish per category (empty slots omitted).
  Future<Map<MealCategory, MealSelection>> getTodaysMenu();

  /// Saves a right-swipe: fills (or replaces) today's slot for the
  /// selection's category and prepends it to history.
  Future<void> saveSelection(MealSelection selection);

  /// Most recent selections, newest first, capped at [AppLimits.historyLimit].
  Future<List<MealSelection>> getHistory();
}
