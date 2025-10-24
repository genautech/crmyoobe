import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/supplier.dart';

class SupplierProvider with ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;

  List<Supplier> get activeSuppliers =>
      _suppliers.where((s) => s.isActive).toList();

  SupplierProvider() {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox<Supplier>('suppliers');
      _suppliers = box.values.toList();
      _suppliers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading suppliers: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      final box = await Hive.openBox<Supplier>('suppliers');
      await box.put(supplier.id, supplier);
      _suppliers.insert(0, supplier);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding supplier: $e');
      }
      rethrow;
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      supplier.updatedAt = DateTime.now();
      final box = await Hive.openBox<Supplier>('suppliers');
      await box.put(supplier.id, supplier);
      
      final index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = supplier;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating supplier: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      final box = await Hive.openBox<Supplier>('suppliers');
      await box.delete(id);
      _suppliers.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting supplier: $e');
      }
      rethrow;
    }
  }

  Supplier? getSupplier(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Supplier? getSupplierByName(String name) {
    try {
      return _suppliers.firstWhere(
        (s) => s.name.toLowerCase() == name.toLowerCase() ||
               s.company.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;

    final lowerQuery = query.toLowerCase();
    return _suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(lowerQuery) ||
             supplier.company.toLowerCase().contains(lowerQuery) ||
             supplier.category.toLowerCase().contains(lowerQuery) ||
             supplier.email.toLowerCase().contains(lowerQuery) ||
             supplier.phone.contains(query);
    }).toList();
  }

  List<Supplier> getSuppliersByCategory(String category) {
    return _suppliers
        .where((s) => s.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Statistics
  int get totalSuppliers => _suppliers.length;
  int get activeCount => activeSuppliers.length;
  int get inactiveCount => _suppliers.length - activeSuppliers.length;

  double get averageRating {
    if (_suppliers.isEmpty) return 0.0;
    final total = _suppliers.fold(0.0, (sum, s) => sum + s.rating);
    return total / _suppliers.length;
  }

  List<String> get categories {
    return _suppliers
        .where((s) => s.category.isNotEmpty)
        .map((s) => s.category)
        .toSet()
        .toList()
      ..sort();
  }
}
