import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/food_item.dart';
import '../../providers/providers.dart';
import '../../widgets/dish_image.dart';

/// Admin: create or edit one food item, including image upload to
/// Firebase Storage.
class AdminFoodFormScreen extends ConsumerStatefulWidget {
  const AdminFoodFormScreen({super.key, this.existing});

  final FoodItem? existing;

  @override
  ConsumerState<AdminFoodFormScreen> createState() =>
      _AdminFoodFormScreenState();
}

class _AdminFoodFormScreenState extends ConsumerState<AdminFoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _prepTimeController;

  late String _id;
  late MealCategory _category;
  late String _region;
  late bool _isVeg;
  late Difficulty _difficulty;
  late double _popularity;

  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _id = e?.id ?? const Uuid().v4();
    _nameController = TextEditingController(text: e?.name ?? '');
    _imageUrlController = TextEditingController(text: e?.imageUrl ?? '');
    _prepTimeController =
        TextEditingController(text: (e?.prepTime ?? 30).toString());
    _category = e?.category ?? MealCategory.breakfast;
    _region = e?.region ?? AppRegions.panIndia;
    _isVeg = e?.isVeg ?? true;
    _difficulty = e?.difficulty ?? Difficulty.easy;
    _popularity = (e?.popularityScore ?? 50).toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 82,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final url = await ref
          .read(foodRepositoryProvider)
          .uploadFoodImage(File(picked.path), _id);
      _imageUrlController.text = url;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = FoodItem(
      id: _id,
      name: _nameController.text.trim(),
      category: _category,
      imageUrl: _imageUrlController.text.trim(),
      region: _region,
      isVeg: _isVeg,
      prepTime: int.parse(_prepTimeController.text.trim()),
      difficulty: _difficulty,
      popularityScore: _popularity.round(),
    );

    try {
      final repo = ref.read(foodRepositoryProvider);
      if (widget.existing == null) {
        await repo.addFood(item);
      } else {
        await repo.updateFood(item);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;

    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'Add Dish' : 'Edit Dish')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Image preview + upload
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 180,
                child: DishImage(imageUrl: _imageUrlController.text.trim()),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  style: IconButton.styleFrom(
                      backgroundColor: AppTheme.saffron,
                      foregroundColor: Colors.white),
                  tooltip: 'Upload from gallery',
                  onPressed: _uploading ? null : _pickAndUploadImage,
                  icon: _uploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.upload_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Dish name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MealCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in MealCategory.values)
                  DropdownMenuItem(value: c, child: Text('${c.emoji} ${c.label}')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: AppRegions.dishRegions.contains(_region)
                  ? _region
                  : AppRegions.panIndia,
              decoration: const InputDecoration(labelText: 'Region'),
              items: [
                for (final r in AppRegions.dishRegions)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (v) => setState(() => _region = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Prep time (min)'),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0 || n > 600) {
                        return 'Enter 1–600';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<Difficulty>(
                    value: _difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: [
                      for (final d in Difficulty.values)
                        DropdownMenuItem(value: d, child: Text(d.label)),
                    ],
                    onChanged: (v) => setState(() => _difficulty = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vegetarian',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              value: _isVeg,
              activeColor: AppTheme.vegGreen,
              onChanged: (v) => setState(() => _isVeg = v),
            ),
            Text('Popularity: ${_popularity.round()}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _popularity,
              max: 100,
              divisions: 100,
              activeColor: AppTheme.saffron,
              onChanged: (v) => setState(() => _popularity = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(isNew ? 'Add dish' : 'Save changes'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
