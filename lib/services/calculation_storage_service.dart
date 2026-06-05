import 'package:hive_flutter/hive_flutter.dart';

import '../models/saved_calculation.dart';

class CalculationStorageService {
  CalculationStorageService._();
  static final CalculationStorageService instance = CalculationStorageService._();

  static const _boxName = 'saved_calculations';
  Box<String>? _box;

  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      // Hive may already be initialized in tests.
    }
    _box = await Hive.openBox<String>(_boxName);
  }

  Box<String> get box {
    final box = _box;
    if (box == null) throw StateError('CalculationStorageService not initialized');
    return box;
  }

  Future<List<SavedCalculation>> getAll() async {
    final items = <SavedCalculation>[];
    for (final value in box.values) {
      items.add(SavedCalculation.fromJsonString(value));
    }
    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return items;
  }

  Future<SavedCalculation?> getById(String id) async {
    final raw = box.get(id);
    if (raw == null) return null;
    return SavedCalculation.fromJsonString(raw);
  }

  Future<void> save(SavedCalculation calculation) async {
    await box.put(calculation.id, calculation.toJsonString());
  }

  Future<void> delete(String id) async {
    await box.delete(id);
  }
}
