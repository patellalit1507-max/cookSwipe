import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/food_item.dart';
import '../../providers/providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/food_card.dart';
import 'admin_food_form_screen.dart';

/// Admin: browse / search / add / edit / delete food items in Firestore.
/// Reachable from Settings only when users/{uid}.role == 'admin'.
class AdminFoodListScreen extends ConsumerStatefulWidget {
  const AdminFoodListScreen({super.key});

  @override
  ConsumerState<AdminFoodListScreen> createState() =>
      _AdminFoodListScreenState();
}

class _AdminFoodListScreenState extends ConsumerState<AdminFoodListScreen> {
  List<FoodItem>? _foods;
  String _filter = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _foods = null;
      _error = null;
    });
    try {
      final foods = await ref
          .read(foodRepositoryProvider)
          .getAllFoods(forceRefresh: true);
      if (mounted) setState(() => _foods = foods);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _openForm([FoodItem? existing]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminFoodFormScreen(existing: existing),
      ),
    );
    if (changed == true) {
      ref.invalidate(allFoodsProvider);
      await _load();
    }
  }

  Future<void> _delete(FoodItem food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${food.name}"?'),
        content: const Text('This removes the dish for all users.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.nonVegRed,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(foodRepositoryProvider).deleteFood(food.id);
      ref.invalidate(allFoodsProvider);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${food.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final foods = _foods;
    final visible = foods
        ?.where(
            (f) => f.name.toLowerCase().contains(_filter.trim().toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Food Items')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.saffron,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add dish'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Filter by name…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          if (foods != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${visible!.length} of ${foods.length} dishes',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          Expanded(child: _buildList(visible)),
        ],
      ),
    );
  }

  Widget _buildList(List<FoodItem>? visible) {
    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load dishes',
        message: _error!,
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    if (visible == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (visible.isEmpty) {
      return const EmptyState(
        icon: Icons.no_meals_rounded,
        title: 'No dishes',
        message: 'Add a dish with the button below.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96, top: 4),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final food = visible[index];
        return FoodListTile(
          name: food.name,
          imageUrl: food.imageUrl,
          isVeg: food.isVeg,
          subtitle:
              '${food.category.label} • ${food.region} • ${food.prepTime} min',
          onTap: () => _openForm(food),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _delete(food),
          ),
        );
      },
    );
  }
}
